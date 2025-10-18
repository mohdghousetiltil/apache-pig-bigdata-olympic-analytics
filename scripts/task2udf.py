
# Function to convert None (null) to 0

from org.apache.pig.scripting import Pig

def NullToZero(value):

    if value is None:
        return 0
    else:
        return value

# Registering the UDF
if __name__ == "__main__":
    Pig.register(NullToZero, "NullToZero")
