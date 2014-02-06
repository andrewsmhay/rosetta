# Rosetta
How can you secure your server if you have no idea what files, registry keys, users, groups, services, or other artifacts are created when an application is installed? Most vendor documentation fails to detail the intricacies of an application’s installation footprint down to individual files. This makes securing the application, not to mention the development of enterprise policies and procedures for the application, an arduous and ultimately ineffective task.

Using a combination of malware analysis techniques, package management utilities, and some homegrown tools, anyone can understand exactly what an application is going to do to your server and how its installation impacts your attack surface area. With this knowledge in hand, an organization can translate the newly created application map to Chef, Puppet, and RightScale configuration scripts to better automate its server and application fleet deployments. The map can also be used to help tighten controls for more accurate and continuous operational and security monitoring of applications.

Rosetta was designed to automate the pre- and post-installation information gathering process so that security analysts can better understand what files, directories, and metadata changes occur on a system before it goes into production. Rosetta works on Linux and Windows distributions.

## Requirements
* require 'rbconfig'
* require 'find'
* require 'etc'
* require 'diffy'

You must also install Ruby 1.8+ and it is recommended that you install git for easy downloading of the repository.

## Installation on Windows:

The [diffy](https://github.com/samg/diffy) gem requires the GNU `which` and `diff` tools. To install them, there are two options:

1.  install unxutils <http://sourceforge.net/projects/unxutils>

    note that these tools contain diff 2.7 which has a different handling of whitespace in the diff results. This makes Diffy spec tests yielding one fail on Windows.

2.  install these two individually from the gnuwin32 project
    <http://gnuwin32.sourceforge.net/>

    note that this delivers diff 2.8 which makes Diffy spec pass even on Windows.

Then make sure the `bin` folder is in your system path.

## Usage

```
./rosetta.rb [options] <i>pre</i> | <i>post | final</i>

e.g.
<b>./rosetta.rb pre</b>

This is a Debian / Ubuntu distro using the apt package manager.

Footprinting root filesystem...
Finished footprinting root filesystem. Results stored in filesystem.pre.

Footprinting network services...
Finished footprinting network ports. Results stored in net_services.pre.

Footprinting groups...
Finished footprinting groups. Results stored in group.pre.

Footprinting users...
Finished footprinting users. Results stored in user.pre.

Footprinting service startup state...
Finished footprinting service startup state. Results stored in services.pre
```

You must then install the application or application stack. Upon completion, continue with the <i>post</i> and <i>final</i> analysis.

```
<b>./rosetta.rb post</b>

This is a Debian / Ubuntu distro using the apt package manager.

Footprinting root filesystem...
Finished footprinting root filesystem. Results stored in filesystem.post.

Footprinting network services...
Finished footprinting network ports. Results stored in net_services.post.

Footprinting groups...
Finished footprinting groups. Results stored in group.post.

Footprinting users...
Finished footprinting users. Results stored in user.post.

Footprinting service startup state...
Finished footprinting service startup state. Results stored in services.post.

<b>./rosetta.rb final</b>

Initalizing post-analysis comparisons...
Identifying probable configuration files...
Post-analysis comparisons completed.
```

(Note: best to run all commands as root or via a user with 'sudo' rights)

You may specify individual footprints, if you only want a few of them.

```
<b>./rosetta.rb -ns pre</b>
This is a Debian / Ubuntu distro using the apt package manager.

Footprinting network services...
Finished footprinting network ports. Results stored in net_services.pre.

Footprinting service startup state...
Finished footprinting service startup state. Results stored in services.pre.
```

Run <b>`./rosetta.rb -h`</b> to see a list of the options.

## Generated Files
The scripts generate pre, post, and out (final) files for each configuration item tracked.

#### Services configured to start, by run level
* services.pre
* services.post
* services.out

#### Probable configuration files
* config_files.out

#### File system
* filesystem.pre
* filesystem.post
* filesystem.out

#### Groups
* group.pre
* group.post
* group.out

#### Listening services
* services.pre
* services.post
* services.out

#### Services set to start
* startup.pre
* startup.post
* startup.out

#### Users
* user.pre
* user.post
* user.out

## References
Presentation at BSidesLV 2013 on the Rosetta Stone Methodology - <a href="http://www.youtube.com/watch?v=cB8V-csHq8E" target="new">http://www.youtube.com/watch?v=cB8V-csHq8E</a>

## Contact

To provide any feedback or ask any questions please reach out to Andrew Hay on Twitter at <a href="http://twitter.com/andrewsmhay" target="new">@andrewsmhay</a> or CloudPassage at <a href="http://twitter.com/cloudpassage" target="new">@cloudpassage</a>.

## About CloudPassage
CloudPassage is the leading cloud infrastructure security company and creator of Halo, the industry's first and only security and compliance platform purpose-built for elastic cloud environments. Halo's patented architecture operates seamlessly across any mix of software-defined data center, public cloud, and even hardware infrastructure. Industry-leading enterprises including multiple trust Halo to protect their cloud and software-defined datacenter environments. Headquartered in San Francisco, CA, CloudPassage is backed by Benchmark Capital, Tenaya Capital, Shasta Ventures, and other leading investors. For more information, please visit <a href="http://www.cloudpassage.com" target="new">http://www.cloudpassage.com</a>.

CloudPassage® and Halo® are registered trademarks of CloudPassage, Inc.