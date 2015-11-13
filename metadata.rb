name             'tomcat-all'
maintainer       'Sayantan Das'
maintainer_email 'sayantan13@gmail.com'
license          'GPL'
description      'Installs/Configures tomcat'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.1'

depends 'ark', '~> 0.9.0'
#depends 'java', '~> 1.31.0'
depends 'apt', '~> 2.4.0'
#depends "java"

supports 'ubuntu', '= 12.04'
supports 'centos', '>= 6.4'
supports 'redhat', '>= 6.4'


