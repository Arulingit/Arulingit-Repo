#learning the connect to oracle database-commtin second
import oracledb
import getpass
connection = oracledb.connect(user="hr", password=userpwd,dsn="localhost/orclpdb")
username="akubendran"
userpwd = os.environ.get("PYTHON_PASSWORD")
host = "localhost"
port = 1521
service_name = "orclpdb"

dsn = f'{username}/{userpwd}@{host}:{port}/{service_name}'
connection = oracledb.connect(dsn)