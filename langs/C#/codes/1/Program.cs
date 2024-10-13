using System;
using System.Linq;
using System.Collections.Generic;
using mdl;
using System.Runtime.InteropServices.Marshalling;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Net.WebSockets;
using System.Net;
using System.Reflection;
using System.Reflection.Metadata.Ecma335;
using System.Collections;
using System.Xml.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks.Dataflow;

namespace kpptyata
{
    class Program
    {
        static void Main()
        {
            while (true)
            {
                var a = "mov a 1, mov b 1, mov c 0, mov d 26, jnz c 2, jnz 1 5, mov c 7, inc d, dec c, jnz c -2, mov c a, inc a, dec b, jnz b -2, mov b c, dec d, jnz d -6, mov c 18, mov d 11, inc a, dec d, jnz d -2, dec c, jnz c -5".Split(", ");
                var ans = SimpleAssembler.Interpret(a);
                Utils.Print(ans.ToList());
                Console.ReadKey();
            }
        }
    }

    public static class SimpleAssembler
    {
        public static Dictionary<string, int> Interpret(string[] program)
        {
            var variables = new Dictionary<string, int>();

            int i = -1;
            while (i < program.Length - 1)
            {
                i++;
                var tokens = program[i].Split(' ');

                Console.WriteLine(string.Join(" ",  program[i]));
                Utils.Print(variables.ToList());
                
                switch (tokens[0])
                {
                    case "mov":
                        if (variables.ContainsKey(tokens[2])) variables[tokens[1]] = variables[tokens[2]];
                        else variables[tokens[1]] = Convert.ToInt32(tokens[2]);
                        break;
                    case "inc":
                        variables[tokens[1]]++;
                        break;
                    case "dec":
                        variables[tokens[1]]--;
                        break;
                    case "jnz":
                        int step = Convert.ToInt32(tokens[2]) - 1;
                        if (variables.ContainsKey(tokens[1])) { 
                            //Console.WriteLine("     " + step + " " + i + " " + tokens[1] + " " + variables[tokens[1]]);
                            if (variables[tokens[1]] != 0) i += step; }
                        else if (tokens[1] != "0") i += step;
                        if (i < 0) i = -1;
                        break;
                    default: break;
                }
            }
            return variables;
        }
    }

    public class Utils
    {
        public static void Print<T>(List<T> arr) 
        {
            Console.WriteLine("##############");
            foreach (T i in arr)
            {
                Console.WriteLine(i);
            }
            Console.WriteLine("##############");
        }
    }

    public class Utils0
    {
        public static int Print<T>(List<T> arr)
        {
            Console.WriteLine("##############");
            foreach (T i in arr)
            {
                Console.WriteLine(i);
            }
            Console.WriteLine("##############");
            return 0;
        }
    }
}

