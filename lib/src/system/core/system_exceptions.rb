# Adds a couple of necessary exceptions

# Thrown if there is a critical error in the Database e.g. when requesting a table that doesnt exist.
class DBError < Exception; end

# Thrown if there a critical parsing error occured e.g. when the syntax is wrong.
class ParsingError < Exception; end

# Thrown if there is a critical render error detected e.g. if a textures size is to low.
class RenderError < Exception; end

# Thrown if there is a security error detected e.g. if the security system fails.
class SecurityError < Exception; end

# Thrown if there is a error in a compressed file is detedcted e.g. the md5 checksum is wrong.
class ZipError < Exception; end