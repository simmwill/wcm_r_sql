
## Connecting R and SQL at WCM (Mac OSX)

Much of this guide is taken from Michael Kleehammer’s [guide to
connecting SQL Server to Mac
OSX](https://github.com/mkleehammer/pyodbc/wiki/Connecting-to-SQL-Server-from-Mac-OSX).
Most/all credit goes to him!

### Steps

#### 1. Software prerequisites

R, RStudio, and packages (`odbc`, `DBI`)

#### 2. Dealing with drivers, etc.

##### **Install FreeTDS and unixODBC**

The connection to SQL Server will be made using the unixODBC driver
manager and the FreeTDS driver. Installing them is most easily done
using homebrew, the Mac package manager.

On your Mac, open the **Terminal** (analogous to the Windows Command
Prompt) and enter the following:

``` r
brew update
brew install unixodbc freetds
```

##### **Edit the `freetds.conf` configuration file**

Ensure the `freetds.conf` file is located in directory
`/usr/local/etc/`, which will be a symlink to the actual file as
installed by Homebrew. To access this directory:

-   Open Finder
-   Select the **Go** menu at the top of your screen, and click **Go to
    Folder…**
-   Type in the filepath `/usr/local/etc/`, which should open a Finder
    window at that location

(If it’s not here, check the specific location of the freetds.conf file
by running `tsql -C`.)

The default file already contains a standard example configuration, but
all you need to do is add your server information to the end, as
follows:

``` r
# You can add an optional comment, e.g., "Added on [DATE]"
[MYMSSQL]
host = VITS-ARCHSQLP04.a.wcmc-ad.net
port = 1433
tds version = 7.3
```

Test the connection using the tsql utility,
e.g. `tsql -S MYMSSQL -U cumc\\[YOUR CWID]`, then entering your
password. (Note that no text or character placeholders will appear as
you type your password.)

If this works, you should see the following:

``` r
locale is "en_US.UTF-8"
locale charset is "UTF-8"
using default charset "UTF-8"
1>
```

At this point you can run SQL queries, e.g. `SELECT @@VERSION`, but
you’ll need to enter `GO` on a separate line to actually execute the
query. Type `exit` to get out of the interactive SQL session.

##### **Edit the `odbcinst.ini` and `odbc.ini` configuration files**

Run `odbcinst -j` to get the location of the `odbcinst.ini` and
`odbc.ini` files (probably in directory `/usr/local/etc/`).

Edit `odbcinst.ini` to include the following:

``` r
[FreeTDS]
Description=FreeTDS Driver for Linux & MSSQL
Driver=/usr/local/lib/libtdsodbc.so
Setup=/usr/local/lib/libtdsodbc.so
UsageCount=1
```

Edit `odbc.ini` to include the following:

``` r
[MYMSSQL]
Description         = Test to SQLServer
Driver              = FreeTDS
Servername          = MYMSSQL
```

**STUCK ON THIS BIT** Check that all is OK by running
`isql MYMSSQL cumc\\[YOUR UNI]` mypassword. You should see the
following:

``` r
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
```

You can enter SQL queries at this point if you like. Type quit to exit
the interactive session.

## **If you have a MacBook with an M1 chip!**

Run the following in your Terminal:

``` r
sudo ln -s /opt/homebrew/lib/ /usr/local/lib
sudo ln -s /opt/homebrew/include/ /usr/local/include
```
