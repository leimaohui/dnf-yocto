%global gitrev bbc0801
%define confdir %{_sysconfdir}/dnf

Name:		dnf
Version:	0.2.3
Release:	1.git%{gitrev}%{?dist}
Summary:	A highly experimental Yum replacement on top of libsolv.
Group:		System Environment/Base
License:	GPLv2+
URL:		https://github.com/akozumpl/dnf
Source0:	dnf-%{gitrev}.tar.xz
BuildArch:	noarch
BuildRequires:	cmake python2
Requires:	python-hawkey >= 0.2.1-1

%description
A highly experimental Yum replacement on top of libsolv.

%prep
%setup -q -n dnf

%build
%cmake .
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

%files
%{_bindir}/*
%{python_sitelib}/dnf/*
%config(noreplace) %{confdir}/dnf.conf

%changelog
* Mon May 7 2012 Aleš Kozumplík <akozumpl@redhat.com> - 0.2.3-1.gitbbc0801%{?dist}
- Fix assert in hawkey's sack.c.

* Fri May 4 2012 Aleš Kozumplík <akozumpl@redhat.com> - 0.2.2-6.git6787583%{?dist}
- support plain 'dnf update'.
- disable plugins.

* Thu Apr 26 2012 Aleš Kozumplík <akozumpl@redhat.com> - 0.2.1-2.gitde732f5%{?dist}
- Create 'etc/dnf/dnf.conf'.

* Wed Apr 25 2012 Aleš Kozumplík <akozumpl@redhat.com> - 0.2.0-2.git70753dd%{?dist}
- New version.

* Thu Apr 12 2012 Aleš Kozumplík <akozumpl@redhat.com> - 0.1-0.git833c054%{?dist}
- Initial package.
