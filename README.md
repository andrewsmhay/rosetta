#Rosetta
How can you secure your server if you have no idea what files, registry keys, users, groups, services, or other artifacts are created when an application is installed? Most vendor documentation fails to detail the intricacies of an application’s installation footprint down to individual files. This makes securing the application, not to mention the development of enterprise policies and procedures for the application, an arduous and ultimately ineffective task.

Using a combination of malware analysis techniques, package management utilities, and some homegrown tools, anyone can understand exactly what an application is going to do to your server and how its installation impacts your attack surface area. With this knowledge in hand, an organization can translate the newly created application map to Chef, Puppet, and RightScale configuration scripts to better automate its server and application fleet deployments. The map can also be used to help tighten controls for more accurate and continuous operational and security monitoring of applications.

Rosetta was designed to automate the pre- and post-installation information gathering process so that security analysts can better understand what files, directories, and metadata changes occur on a system before it goes into production.

##Requirements
* require 'rbconfig'
* require './lib/determineos.rb'
* require 'find'
* require 'etc'

##Usage

<pre>
./rosetta.rb <i>package_name</i> <i>pre|post|final</i>

e.g.
<b>./rosetta.rb tomcat7 pre</b>

This is a Debian / Ubuntu distro using the apt package manager.

Footprinting root filesystem...
Finished footprinting root filesystem. Results stored in filesystem.pre.

Footprinting package contents...
Finished footprinting tomcat7. Results stored in tomcat7.package.

Footprinting services...
Finished footprinting network ports. Results stored in services.pre.

Footprinting groups...
Finished footprinting groups. Results stored in group.pre.

Footprinting users...
Finished footprinting users. Results stored in user.pre.

Footprinting service startup state...
Finished footprinting service startup state. Results stored in chkconfig.pre.

</pre>

(Note: best to run as root or via a user with 'sudo' rights)

##References
Presentation at BSidesLV 2013 on the Rosetta Stone Methodology - <a href="http://www.youtube.com/watch?v=cB8V-csHq8E" target="new">http://www.youtube.com/watch?v=cB8V-csHq8E</a>

##Contact

To provide any feedback or ask any questions please reach out to Andrew Hay on Twitter at <a href="http://twitter.com/andrewsmhay" target="new">@andrewsmhay</a> or CloudPassage at <a href="http://twitter.com/cloudpassage" target="new">@cloudpassage</a>.

##About CloudPassage
CloudPassage is the leading cloud infrastructure security company and creator of Halo, the industry's first and only security and compliance platform purpose-built for elastic cloud environments. Halo's patented architecture operates seamlessly across any mix of software-defined data center, public cloud, and even hardware infrastructure. Industry-leading enterprises including multiple trust Halo to protect their cloud and software-defined datacenter environments. Headquartered in San Francisco, CA, CloudPassage is backed by Benchmark Capital, Tenaya Capital, Shasta Ventures, and other leading investors. For more information, please visit <a href="http://www.cloudpassage.com" target="new">http://www.cloudpassage.com</a>.

CloudPassage® and Halo® are registered trademarks of CloudPassage, Inc.