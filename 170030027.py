"""
    Lexical Analyzer by Naresh Kumar Kaushal, 170030027, CSE Fourth Year
"""

class lexicanAnalyser:

    """
        Constructor
    """

    def __init__(self):
        self.fh = open("input_code.txt") 
        self.keywords = {"if", "else", "int", "return", "string", "float", "double", "char"} 
        self.dataTypes = {"int", "float", "double", "string", "char"}
        self.operators = {'+', '-', '*', '=', '/', '%'}
        self.symbolTable = {}
        self.tokenTable = {}
        self.isFunction = False  ## flags if function has started
        self.prevToken = ""      ## To store the previous token detected
        self.stack = []          ## to check for balanced parenthesis



    """
        removeComments State detects single line // and multiline comments /**/.        
    """

    def removeComments(self):

        c = self.fh.read(1)
        
        ## For multiline comments
        if(c == '*'):  ## if '*' is read after '/'
            while True:   ## run until '*/' or comment is closed
                c = self.fh.read(1)
                if(c == '*'):
                    nextChar = self.fh.read(1)
                    if(nextChar == '/'):
                        break
                if(not c):   ## If reached end of file(EOF) and comments are not closed
                    assert False, "Multiline Comments are not closed."  ## halt the program

        ## For single line comments
        elif(c == '/'):   ## If '/' is reached after '/'
            while(True):  ## run until new line is reached
                c = self.fh.read(1)
                if(c == '\n'):
                    break
                if(not c):
                    break

        else:
            assert False, "Dangling / forward slash check charcter number {}".format(self.fh.tell())

    


    """
        readIdentifierOrKeyword state detects token as a keyword or identifier it is reached
        when any token starts with alpha or _
        input : buffer = [a-zA-Z_] keyword or identifier is started (Size of buffer is 1 when this function is called).
    """

    def readIdentifierOrKeyword(self, buffer):

        while(True):    ## run until character other than alpha or _ or digit is reached
            c = self.fh.read(1)
            if(c == '_' or c.isalnum()):
                buffer += c
            else:      ## break when character other than alphabet, _ or digit is reached
                break
        
        if(buffer in self.keywords):    ## If read token is keyword

            self.tokenTable[buffer] = "Keyword"
            
            if(self.prevToken in self.keywords):   ## If read keyword is used as a variable name
                assert False, "{} cannot be used as an identifier error at character number {}".format(buffer, self.fh.tell())
            
            elif(buffer in self.dataTypes):  ## if read keyword is a datatype then store it in prev token
                    self.prevToken = buffer

        else:      ## If read token is not a keyword
                      
            self.tokenTable[buffer] = "Identifier" ## Store the identifier in token table

            if self.prevToken in self.dataTypes:   ## If read variable is decalred properly
                if(buffer != 'main'):
                    self.symbolTable[buffer] = self.prevToken

            else:   ## Wrong declaration of identifier
                if(buffer not in self.symbolTable):
                    assert False, "{} is not declared use valid variable definition".format(buffer)



    """
        readNum state detects integer and decimal, it is reached when first digit is read 
        input : buffer = [0-9] any number (size of buffer is 1 when this function is called) or
                        -[0-9] any negative number (size of buffer is 2 when this function is called)
    """

    def readNum(self, buffer):

        isDecimal = False
        while(True):   ## run until any character other than digit is read
            c = self.fh.read(1)
            if(c == '.' and isDecimal == False): ## if '.' is reached first time
                isDecimal = True
                buffer += c
                continue
            elif(c == '.' and isDecimal == True):  ## if '.' is reached second time then halts
                assert False, "Decimal number defined at character number {} is not correct".format(self.fh.tell())

            if(c.isdigit()):
                buffer += c

            elif(c in self.dataTypes or c == ';' or c == ',' or c == ')'):   ## if any character other than digit or one '.' is reached
                break

            else:
                assert False, "Number read is wrong check character number {}, {}".format(self.fh.tell(), buffer)

        self.tokenTable[buffer] = "Num"


    """
        readNegativeNumber function is reached when - is detected if character after - is digit then it will be stored as Num
        otherwise skipped
        input : buffer = "-"
    """


    def readNegativeNumber(self, buffer):

        c = self.fh.read(1)
        if(c.isdigit()):
            buffer += c
            self.readNum(buffer)
        print(self.fh.tell())


    """
       readString state detects string constant in double quotes and this state is reached when first " is detected
       input : buffer = " " "(string type)
    """

    def readString(self, buffer):

        while(True):  ## run until " is detected which tells that string ends
            c = self.fh.read(1)
            buffer += c
            if(c == '"'):
                break
            if(not c):  ## if we reach EOF and string is not closed
                assert False, "String quotes are incomplete"

        if(len(buffer[1:-1]) != 0):  ## strore the string constant with quotes
            self.tokenTable[buffer[1:-1]] = "const"





    """
       readChar state detects char constant in single quotes and this state is reached when first ' is detected
       input : buffer = " ' " (char type)
    """


    def readChar(self, buffer):

        c = self.fh.read(1)   ## read the charcter
        buffer += c;
        c = self.fh.read(1)   ## read the second ' single quote
        if(c == '\''): ## if character read is ' single quote 
            self.tokenTable[buffer] = "const"
        else:   ## if ending quote is not present throw error
            assert False, "single quote after charcter is missing check at character number {}".format(self.fh.tell())






    """
        checkForBalancedBrackets state checks for brackets mismatch and balanced parenthesis 
        it is reached when any open or closed bracket is detected.
    """


    def checkForBalancedBrackets(self, ch):
        if(ch == '(' or ch == '{' or ch == '['):  ## push opening brackets on stack
                self.stack.append(ch)
            
        elif(ch == ')' or ch == '}' or ch == ']'):  ## if character detected is closing bracket
            if(len(self.stack) == 0):  ## if stack is empty then give error
                assert False, "Brackets are not matched properly at character number {}".format(self.fh.tell())

            c = self.stack[-1]  ## get the top element of stack
            
            if((ch == ')' and c != '(') or (ch == '}' and c != '{') or (ch == ']' and c != '[')): ## if parenthesis are not balanced give error
                assert False, "Brackets are not matched properly {}".format(self.fh.tell())

            self.stack.pop()  ## pop the top bracket if closing bracket matches with top bracket in the stack
                





    """
        Start state
    """


    def begin(self):

        buffer = ""
        j = 0
        while True:  ## run until End Of File is reached

            ch = self.fh.read(1)   ## reading the next character

            if(ch == '(' or ch == ')' or ch == '{' or ch == '}' or ch == '[' or ch == ']'): ## if any bracket is detected
                self.checkForBalancedBrackets(ch)

            if not ch: ## If we reach end of file (EOF) then stop
                break 

            elif(ch == '/'):  ## if / is detected then check for comments
                self.removeComments()

            elif(ch == '_' or ch.isalpha()):  ## Read keyword or identifier
                buffer += ch
                self.readIdentifierOrKeyword(buffer)
                self.fh.seek(self.fh.tell()-1)
                buffer = ""

            elif(ch.isdigit()):  ## Read integer or decimal
                buffer += ch
                self.readNum(buffer)
                self.fh.seek(self.fh.tell()-1)
                buffer = ""

            elif(ch == '"'):  ## read string literal
                buffer += ch
                self.readString(buffer)
                buffer = ""

            elif(ch == '\''):  ## read char
                buffer = ""
                self.readChar(buffer)
                buffer = ""

            elif(ch == '('):  ## if '(' is detected this signifies function definition has started
                self.prevToken = ""  ## flush any previous datatype if '(' is detected
                self.isFunction = True

            elif(ch == ')' or ch == '{' or ch == '}' or ch == ';'): 
                self.prevToken = "" ## flush previous data type if any bracket is detected
                if(ch == ')'):   ## if ')' is detected then function definition ends
                    self.isFunction = False

            elif(ch == ','):  
                print(self.prevToken)
                if(self.isFunction):  ## if we are reading function arguments then flush previous datatypes after detecting ','
                    self.prevToken = ""
            
            elif(ch == '-'): ## if negative sign is detected then check if we are reading negative number
                buffer = "-"
                self.readNegativeNumber(buffer)
                self.fh.seek(self.fh.tell()-1)
                buffer = ""

            elif(ch == '='):
                self.prevToken = ""


            elif(ch == '\n' or ch == ' ' or ch == '\t' or ch in self.operators):  ## Just skip these characters
                continue

            else:  ## If any other character is read then give error
                assert False, "Invalid character. Check character number {}".format(self.fh.tell())

        if(len(self.stack) != 0):  ## if EOF is reached but still some brackets are not closed then halt the program
            assert False, "Brackets are not balanced"

  
test = lexicanAnalyser()

test.begin()   ## begins the lexical analyser

print("\nSYMBOL TABLE\n")  ## print the symbol table
print("lexeme - DataType")
for k, v in test.symbolTable.items():
    print("{} - {}".format(k, v))
print('\n')

print("TOKEN TABLE\n")  ## print the token table
print("Token - type")
for k, v in test.tokenTable.items():
    print("{} - {}".format(k, v))