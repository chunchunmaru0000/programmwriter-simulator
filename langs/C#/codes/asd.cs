using System;
using System.ComponentModel.DataAnnotations;
using System.IO;

namespace MyPycCompiler
{
    internal class Program
    {
        static void Main(string[] args)
        {
            string[] tokens = new string[3] { "создать", "бд", "негр" };
            Comp.BeginFolder();
            int type = Comp.Definitor(ref tokens);
            Comp.Proceed(type, ref tokens);

            Console.Read();
        }
    }

    public static class Comp
    {
        public static string DbsPath = @"C:\Users\user\Desktop\testfold";
        public static string Lister = "dbList.txt";
        public static string DbLister = DbsPath + '\\' + Lister;

        public static void BeginFolder()
        {
            if (!File.Exists(DbLister))
            {
                using (FileStream stream = File.Create(DbLister))
                {
                    stream.Write(new System.Text.UTF8Encoding(true).GetBytes(""), 0, 0);
                }
                Console.WriteLine("created dbLIST");
            }
            else
            {
                Console.WriteLine("dbLIST was");
            }
        }

        public static int Definitor(ref string[] tokens)
        {
            int type = 0;
            switch (tokens[0])
            {
                case "создать":
                    switch (tokens[1])
                    {
                        case "бд":
                            type = 0;
                            break;
                        case "тб":
                            type = 1;
                            break;
                        default:
                            Console.WriteLine("не создаваемо");
                            break;
                    }
                    break;
                default:
                    Console.WriteLine("не определено");
                    break;
            }
            return type;
        } 
        public static void Proceed(int type, ref string[] tokens)
        {
            switch (type)
            {
                case 0:
                    CreateDB(ref tokens);
                    break;
                case 1:
                    CreateTable(ref tokens);
                    break;
                default:
                    break;
            }
        }

        public static void CreateDB(ref string[] tokens)
        {
            using (FileStream stream = new FileStream(DbLister, FileMode.Append))
            {
                byte[] text = new System.Text.UTF8Encoding(true).GetBytes(tokens[2] + '\n');
                stream.Write(text, 0, text.Length);
            }
        }

        public static void CreateTable(ref string[] tokens)
        {

        }
    }
}