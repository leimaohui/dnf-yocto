# fetchspdx
# Fetch_spdx CLI command.
#
# Copyright (C) 2014-2016 Red Hat, Inc.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of
# the GNU General Public License v.2, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY expressed or implied, including the implied warranties of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.  You should have received a copy of the
# GNU General Public License along with this program; if not, write to the
# Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.  Any Red Hat trademarks that are incorporated in the
# source code or documentation are not subject to the GNU General Public
# License and may only be used or replicated with the express permission of
# Red Hat, Inc.
#

from __future__ import absolute_import
from __future__ import unicode_literals
from dnf.cli import commands
from dnf.cli.option_parser import OptionParser
from dnf.i18n import _
from itertools import chain
import dnf.subject

import dnf.exceptions
import hawkey
import logging
import dnf.cli.utils

logger = logging.getLogger('dnf')

class Fetch_srpmCommand(commands.Command):
    """A class containing methods needed by the cli to execute the
    install command.
    """
    nevra_forms = {'install-n': hawkey.FORM_NAME,
                   'install-na': hawkey.FORM_NA,
                   'install-nevra': hawkey.FORM_NEVRA}

    aliases = ('fetchsrpm',) 
    summary = _('Download a srpm file of package on your system')

    @staticmethod
    def set_argparser(parser):
        parser.add_argument('package', nargs='+', metavar=_('PACKAGE'),
                          action=OptionParser.ParseSpecGroupFileCallback,
                          help=_('Package to download'))

    def configure(self):
        """Verify that conditions are met so that this command can run.
        That there are enabled repositories with gpg keys, and that
        this command is called with appropriate arguments.
        """
        demands = self.cli.demands
        demands.sack_activation = True
        demands.available_repos = True
        demands.resolving = True
        demands.root_user = True
        commands._checkGPGKey(self.base, self.cli)
        commands._checkEnabledRepo(self.base, self.opts.filenames)
        self.forms = [self.nevra_forms[command] for command in self.opts.command
                      if command in list(self.nevra_forms.keys())]

    def fetchSRPM(self, pkg_specs):
        """Add for spdx file cp."""
        srcdir_path = self.base.conf.srpm_repodir
        destdir_path = self.base.conf.srpm_download

        '''Obtain yum package list '''
        ypl = self.base.returnPkgLists(
                pkgnarrow = 'all', patterns = pkg_specs)

        # check if the packager has been installed
        #check if the pkg can be found
        if ypl.available:
            install_pkgs = ypl.available
            install_pkgs = install_pkgs + ypl.installed
        else:
            logger.info(_("Error: No matches found."))
            return

        dnf.cli.utils.fetchSPDXorSRPM('srpm', install_pkgs, srcdir_path, destdir_path)

    def run(self):
        self.fetchSRPM(self.opts.pkg_specs)

