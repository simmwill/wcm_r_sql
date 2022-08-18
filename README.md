
<br>

# Connecting R and SQL at WCM (Mac OSX)

Much of this guide is taken from Michael Kleehammer’s [guide to
connecting SQL Server to Mac
OSX](https://github.com/mkleehammer/pyodbc/wiki/Connecting-to-SQL-Server-from-Mac-OSX).
Most/all credit goes to him!

<br>

## Steps

<br>

#### 1. Software prerequisites

Make sure you have R, RStudio, [Homebrew for Mac OS](https://brew.sh/),
and some R packages (`odbc`, `DBI`) installed.

<br>

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

<br>

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

<br>

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

<br>

### **If you have a MacBook with an M1 chip!**

Run the following in your Terminal:

``` r
sudo ln -s /opt/homebrew/lib/ /usr/local/lib
sudo ln -s /opt/homebrew/include/ /usr/local/include
```

For some reason, Macbooks with M1 chips install the files we want to
access in a different place. Running the above creates symlinks
(symbolic “pointer” folders) that R can access without getting confused.

<br>

## Testing your SQL-R connection!

Open RStudio and create a new R script you’ll use to connect to the SQL
server. (If you’re working in an Rproject that will use this connection,
you can name it `connect.R` or something similar and save it in a
logical place.)

Use the following code to create a SQL connection object in your R
environment, using the `DBI` package:

``` r
con <- DBI::dbConnect(odbc::odbc(),
                       Driver = "FreeTDS",
                       Server = "VITS-ARCHSQLP04.a.wcmc-ad.net",
                       Database = "YOUR_DATABASE",  # e.g. "COVID_DATALAKE"
                       Port = 1433,
                       # enter cumc\cwid at the prompt
                       uid = "cumc\\YOUR_CWID",  # e.g. "cumc\\wis4002"
                       # cwid password
                       pwd = rstudioapi::askForPassword("Database password")
)
```

When you run this code, three things should happen:

1.  RStudio will ask for your password. Enter the password you normally
    use to access WCM systems with your CWID.
2.  In your R session, you’ll see a new object called `con` (or whatever
    you named the connection object above - it doesn’t matter).
3.  The “Connections” pane on RStudio may populate with the names of
    many WCM SQL tables. (If not, don’t worry. You can usually trigger
    this by rerunning the code above via the Connections pane \> Connect
    \> R Console.)

Now, run a simple SQL query to test your connection! Here’s an example
using the `DBI::dbGetQuery` function.

``` r
# selects first row of table

dbGetQuery(con,  # or whatever your connection is named
           "SELECT TOP(1) *
           FROM ___.___")  # schema.table
```

<br>

## Conclusion

That’s it! If you want to learn about seamlessly integrating SQL and
`dplyr`, check out my [short
presentation](https://simmwill.github.io/dbplyr-pres.html) on the
`dbplyr` package.
