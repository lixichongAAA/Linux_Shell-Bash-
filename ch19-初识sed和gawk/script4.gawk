BEGIN {
print "The latest list of users and shells"
print "UerID   \t Shell"
print "-----   \t -----"
FS=":"
}

{
print $1 "       \t " $7
}

END {
print "The concludes the listing"
}
