# What is it?
sys_assert is a basic functional testing framework for shell scripts and system administration tasks. You can:

* Test your shell scripts and make sure they do what they are supposed to do
* Test configuration management systems to make sure they applied the changes you expected
* Write tests for any system administration work


Think of your system as running the codebase. sys_assert will *assert* on tests about the system.

# Test What?
What can sys_assert test on? At the moment it is

* Exit codes
* Stdout
* File content, permissions and ownership
* Processes
* Services
* And More! (when I implement them)

# Running Tests

There are three ways that sys_assert can test your system

* In a pipeline
* By letting sys_assert run the script/command
* Running in a standalone mode, asserting a system after something has run

## Pipeline
Pipeline mode feels like the right way to do the test. The only disadvantage is the exit code cannot be determined.

     $ myscript.sh | assert --stdout-contains "backup finished" --file-#/var/mybackup.tgz#-exists

## Running the command/script
sys_assert can also run the command for you. The exit code of the command can be determined if this style of execution is used

     $ assert -c "myscript.sh" --exit-code-is 0 --stdout-contains "backup finished" --file-#/var/mybackup.tgz#-exists

## Standalone
The last way to use sys_assert is to use it after-the-fact. This could be useful for testing the success of configuration management tools

     $ puppet agent --test --trace
     $ assert --file-#/etc/httpd/conf.d/myvhost.conf#-exists \
         --service-#httpd#-is-running \

# Other pieces of the puzzle
sys_assert should be part of your continuous intergration system. To take full advantage of systems testing, you will need throwaway coupute resources as part of your build.

If you are looking for throwaway compute reosurces, swing by another project I've been hacking at called [minicloud](http://github.com/ryandoyle/minicloud).
