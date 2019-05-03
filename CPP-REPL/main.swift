//
//  main.swift
//  C++ REPL
//
//  Created by Isaac Raval.
//  Copyright Isaac Raval 2018. All rights reserved.
//
//According to openjdk.java.net a REPL is "an interactive programming tool which loops, continually reading user input, evaluating the input, and printing the value of the input or a description of the state change the input caused."

import Foundation

//Mark: Constants
let HELP = "h"
let QUIT = "q"
var continueREPL = true

//Declare function for shell calls
func shell(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    
    return output
}

//Cleanup and recreate record file
shell("rm record.txt")
shell("echo '' >> record.txt")

//Guide the user
print("REPL interactive programming tool. Type \(HELP) for help. Quit with \(QUIT).")

while (continueREPL){
    //Get line of input from user
    print(" >: ",terminator:"")
    let input = readLine()
    
    //Inputting del removes last line
    if (input == "del") {
        shell("sed -i '' '$d' record.txt")
        print("Deleted last line")
        continue; //return to start of loop
    }

    //Add boiler-plate code
    shell("echo '#include <iostream>\n'  > cpprepl.cpp")
    shell("echo 'using namespace std;\n'  >> cpprepl.cpp")
    shell("echo 'int main()\n{\n'  >> cpprepl.cpp")
    
    //Add input to record file
    if (input != nil && input != HELP && input != QUIT){
        shell("echo '\(input!)' >> record.txt")
    }
    else {
        if (input == HELP) {
            print(#"    This program is a C++ REPL, or: "an interactive programming tool which loops, continually reading user input, evaluating the input, and printing the value of the input or a description of the state change the input caused." Type e.x. cout << "Hello World!" << endl;"#)
        }
        if (input == QUIT) {
            continueREPL = false;
        }
    }
    
    //Add all previous lines of code
    shell("cat record.txt  >> cpprepl.cpp")
    
    //Add boiler-plate code
    shell("echo 'return 0;\n}\n'  >> cpprepl.cpp")
    
    //Compile and run cpp file
    shell("g++ -o cpprepl cpprepl.cpp")
    print(shell("./cpprepl"))
}
