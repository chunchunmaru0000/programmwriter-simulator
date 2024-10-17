﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.IO;

namespace VovaScript
{
    public sealed class AssignStatement : IStatement, IExpression
    {
        public Token Variable;
        public IExpression Expression;
        public object Result;

        public AssignStatement(Token variable, IExpression expression) 
        { 
            Variable = variable;
            Expression = expression;
        }

        public void Execute()
        {
            object Result = Expression.Evaluated();
            Objects.AddVariable(Variable.View, Result);
        }

        public object Evaluated()
        {
            Execute();
            return Result is IClass ? ((IClass)Result).Clone() : Result;
        }

        public IStatement Clone() => new AssignStatement(Variable.Clone(), Expression.Clon());

        public IExpression Clon() => new AssignStatement(Variable.Clone(), Expression.Clon());

        public override string ToString() => $"{Variable} = {Expression};";
    }

    public sealed class PrintStatement : IStatement, IExpression
    {
        public IExpression Expression;
        public object Result;

        public PrintStatement(IExpression expression) => Expression = expression;

        public void Execute()
        {
            object value = Expression.Evaluated();
            if (value is List<object>)
            {
                Result = ListString((List<object>)value);
                Console.WriteLine(Result);
            }
            else if (value is bool)
            {
                Result = (bool)value ? "Истина" : "Ложь";
                Console.WriteLine(Result);
            }
            else if (value is IClass)
            {
                IClass classObject = value as IClass;
                Result = classObject.Clone();
                if (classObject.ContainsAttribute("строкой"))
                {
                    object strokoi = classObject.GetAttribute("строкой");
                    if (strokoi is IClass)
                        if (!(((IClass)strokoi).Body is null))
                            Console.WriteLine(((IClass)strokoi).Body.Execute());
                        else
                            Console.WriteLine(classObject);
                    else
                        Console.WriteLine(classObject);
                }
                else
                    Console.WriteLine(classObject);
            }
            else if (value is string)
            {
                Console.WriteLine(Convert.ToString(value));
                Result = value;
            }
            else
            {
                Console.WriteLine(value);
                Result = value;
            }
        }

        public object Evaluated()
        {
            Execute();
            return Result;
        }

        public IStatement Clone() => new PrintStatement(Expression.Clon());

        public IExpression Clon() => new PrintStatement(Expression.Clon());

        public static string ListString(List<object> list)
        {
            string text = "[";
            int len = list.Count;
            for (int i = 0; i < len; i++)
            {
                object item = list[i];
                if (item is List<object>)
                    text += ListString((List<object>)item);
                else if (item is bool)
                    text += (bool)item ? "Истина" : "Ложь";
                else if (item is string)
                    text += '"' + (string)item + '"';
                else if (item is char)
                    text += '"' + Convert.ToString(item) + '"';
                else if (item is IExpression)
                    text += ((IExpression)item).ToString();
                else
                    text += Convert.ToString(item);

                if (i < len - 1)
                    text += ", ";
            }
            return text + ']';
        }

        public override string ToString() => $"НАЧЕРТАТЬ {Expression};";
    }

    public sealed class IfStatement : IStatement, IExpression
    {
        public IExpression Expression;
        public IStatement IfPart;
        public IExpression[] ElifExps;
        public IStatement[] ElifStats;
        public IStatement ElsePart;
        public IfStatement(IExpression expression, IStatement ifStatement, IExpression[] elifExps, IStatement[] elifStats, IStatement elseStatement)
        {
            Expression = expression;
            IfPart = ifStatement;
            ElifExps = elifExps;
            ElifStats = elifStats;
            ElsePart = elseStatement;
        }

        public IExpression Clon() => new IfStatement(Expression.Clon(), IfPart.Clone(), ElifExps.Select(e => e.Clon()).ToArray(), ElifStats.Select(e => e.Clone()).ToArray(), ElsePart is null ? null : ElsePart.Clone());

        public IStatement Clone() => new IfStatement(Expression.Clon(), IfPart.Clone(), ElifExps.Select(e => e.Clon()).ToArray(), ElifStats.Select(e => e.Clone()).ToArray(), ElsePart is null ? null : ElsePart.Clone());

        public void Execute()
        {
            bool result = HelpMe.GiveMeSafeBool(Expression.Evaluated());
            if (result)
            {
                IfPart.Execute();
                return;
            }
            for (int i = 0; i < ElifExps.Length; i++)
                if (HelpMe.GiveMeSafeBool(ElifExps[i].Evaluated()))
                {
                    ElifStats[i].Execute();
                    return;
                }
            if (ElsePart != null)
                ElsePart.Execute();
        }

        public object Evaluated()
        {
            try
            {
                Execute();
            }
            catch (ReturnStatement ret)
            {
                return ret.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public override string ToString() => $"ЕСЛИ {Expression} ТОГДА {{{IfPart}}} ИНАЧЕ {{{ElsePart}}}";
    }

    public sealed class BlockStatement : IStatement, IExpression
    {
        public List<IStatement> Statements;

        public BlockStatement() => Statements = new List<IStatement>();

        public BlockStatement(List<IStatement> statements) => Statements = statements;

        public void Execute()
        {
            foreach (IStatement statement in Statements)
                statement.Execute();
        }

        public object Evaluated()
        {
            try
            {
                foreach (IStatement statement in Statements)
                    statement.Execute();
            }
            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public IStatement Clone() => new BlockStatement() { Statements = Statements.Select(s => s.Clone()).ToList() };

        public IExpression Clon() => new BlockStatement() { Statements = Statements.Select(s => s.Clone()).ToList() };

        public void AddStatement(IStatement statement) => Statements.Add(statement);

        public override string ToString() => string.Join("|", Statements.Select(s =>'<' + s.ToString() + '>').ToArray());
    }

    public sealed class WhileStatement : IStatement, IExpression
    {
        IExpression Expression;
        IStatement Statement;

        public WhileStatement(IExpression expression, IStatement statement)
        {
            Expression = expression;
            Statement = statement;
        }

        public IStatement Clone() => new WhileStatement(Expression.Clon(), Statement.Clone());

        public IExpression Clon() => new WhileStatement(Expression.Clon(), Statement.Clone());

        public void Execute()
        {
            while(HelpMe.GiveMeSafeBool(Expression.Evaluated()))
            {
                try
                {
                    Statement.Execute();
                }
                catch (BreakStatement)
                {
                    break;
                }
                catch (ContinueStatement)
                {
                    // continue by itself
                }
            }
        }

        public object Evaluated()
        {
            try
            {
                Execute();
            }
            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public override string ToString() => $"{Expression}: {{{Statement}}}";
    }

    public sealed class ForStatement : IStatement, IExpression
    {
        IStatement Definition;
        IExpression Condition;
        IStatement Alter;
        IStatement Statement;

        public ForStatement(IStatement definition, IExpression condition, IStatement alter, IStatement statement)
        {
            Definition = definition;
            Condition = condition;
            Alter = alter;
            Statement = statement;
        }

        public IStatement Clone() => new ForStatement(Definition.Clone(), Condition.Clon(), Alter.Clone(), Statement.Clone());

        public IExpression Clon() => new ForStatement(Definition.Clone(), Condition.Clon(), Alter.Clone(), Statement.Clone());

        public void Execute()
        {
            for (Definition.Execute(); HelpMe.GiveMeSafeBool(Condition.Evaluated()); Alter.Execute())
            {
                try
                {
                    Statement.Execute();
                }
                catch (BreakStatement)
                {
                    break;
                }
                catch (ContinueStatement)
                {
                    // continue by itself
                }
            }
        }

        public object Evaluated()
        {
            try
            {
                Execute();
            }
            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public override string ToString() => $"ДЛЯ {Definition} {Condition} {Alter}: {Statement}";
    }

    public sealed class ForInStatement : IStatement, IExpression
    {
        Token Itter;
        VarAttrSliceNode VarNode;
        IExpression Ratio;
        IStatement Body;

        public ForInStatement(Token itter, VarAttrSliceNode varNode, IExpression ratio, IStatement body)
        {
            Itter = itter;
            VarNode = varNode;
            Ratio = ratio;
            Body = body;
        }

        public IStatement Clone() => new ForInStatement(Itter.Clone(), VarNode, Ratio.Clon(), Body.Clone());

        public IExpression Clon() => new ForInStatement(Itter.Clone(), VarNode, Ratio.Clon(), Body.Clone());

        public void Execute()
        {
            List<object> list = new List<object>();
            int length = 0;
            if (VarNode.ObjName != Parser.IMPOSSIBLE)
            {
                ObjectValue objectValue = HelpMe.GiveMeObject(VarNode.ObjName, VarNode.Attrs, VarNode.Slices);
                Token nameToken = new Token() { View = objectValue.ObjName };

                for (int i = 0; ; i++)
                {
                    try
                    {
                        object ratio = Ratio.Evaluated();
                        list = SliceExpression.Obj2List(ratio);
                        length = list.Count;
                        if (i >= length)
                            break;

                        Objects.AddVariable(Itter.View, list[i]);

                        if (VarNode.ObjName != Parser.IMPOSSIBLE)
                        {
                            IExpression iter = new VariableExpression(Itter);

                            if (objectValue.IsItem && objectValue.IsChild)
                                new SliceAssignStatement(nameToken, VarNode.Slices, VarNode.Attrs, iter, false, false).Execute();
                            else if (objectValue.IsChild)
                                new AttributeAssignStatement(nameToken, VarNode.Attrs, iter).Execute();
                            else if (objectValue.IsItem)
                                new SliceAssignStatement(VarNode.ObjName, VarNode.Slices, VarNode.Attrs, iter, false, true).Execute();
                            else
                                Objects.AddVariable(objectValue.ObjName, list[i]);
                        }

                        Body.Execute();
                    }
                    catch (BreakStatement) { break; }
                    catch (ContinueStatement) { }
                    catch (IndexOutOfRangeException) { 
                        throw new Exception(
                            $"ОКАЗАЛСЯ ЗА ГРАНИЦАМИ ЛИСТА С ДЛИНОЙ <{length}> НА ИТТЕРАЦИИ {i}\n" +
                            $"В ЛИСТЕ <{PrintStatement.ListString(list)}>"
                        ); 
                    }
                }

            }
            else
            {
                for (int i = 0; ; i++)
                {
                    try
                    {
                        object ratio = Ratio.Evaluated();
                        list = SliceExpression.Obj2List(ratio);
                        length = list.Count;
                        if (i >= length)
                            break;

                        Objects.AddVariable(Itter.View, list[i]);
                        Body.Execute();
                    }
                    catch (BreakStatement) { break; }
                    catch (ContinueStatement) { }
                    catch (IndexOutOfRangeException)
                    {
                        throw new Exception(
                            $"ОКАЗАЛСЯ ЗА ГРАНИЦАМИ ЛИСТА С ДЛИНОЙ <{length}> НА ИТТЕРАЦИИ {i}\n" +
                            $"В ЛИСТЕ <{PrintStatement.ListString(list)}>"
                        );
                    }
                }
            }
        }

        public object Evaluated()
        {
            try
            {
                Execute();
            }
            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public override string ToString() => $"ДЛЯ {Itter}" + (VarNode.ObjName == Parser.IMPOSSIBLE ? "" : $"КОТОРЫЙ/АЯ/ОЕ {VarNode}") + $" В {VarNode}{{{Body}}}";
    }

    public sealed class BreakStatement : Exception, IStatement, IExpression
    {
        public void Execute() => throw this;

        public IStatement Clone() => new BreakStatement();

        public IExpression Clon() => new BreakStatement();

        public object Evaluated() => "ВЫЙТИ";

        public override string ToString() => "ВЫЙТИ;";
    }

    public sealed class ContinueStatement : Exception, IStatement, IExpression
    {
        public void Execute() => throw this;

        public IStatement Clone() => new ContinueStatement();

        public IExpression Clon() => new ContinueStatement();

        public object Evaluated() => "ПРОДОЛЖИТЬ";

        public override string ToString() => "ПРОДОЛЖИТЬ;";
    }

    public sealed class ReturnStatement : Exception, IStatement, IExpression
    {
        public IExpression Expression;
        public object Value;

        public ReturnStatement(IExpression expression) => Expression = expression;

        public void Execute()
        {
            Value = Expression.Evaluated();
            throw this;
        }

        public object Evaluated()
        {
            Value = Expression.Evaluated();
            throw this;
        }

        public IStatement Clone() => new ReturnStatement(Expression.Clon());

        public IExpression Clon() => new ReturnStatement(Expression.Clon());

        public object GetResult() => Value;

        public override string ToString() => $"ВЕРНУТЬ {Value};";
    }

    public sealed class DeclareFunctionStatement : IStatement, IExpression
    {
        public Token Name;
        public Token[] Args;
        public IStatement Body;
        public IClass Pool;
        public IClass Function;

        public DeclareFunctionStatement(Token name, Token[] args, IStatement body, IClass pool = null)
        {
            Name = name;
            Args = args;
            Body = body;
            Pool = pool;
        }

        public IStatement Clone() => new DeclareFunctionStatement(Name.Clone(), Args.Select(a => a.Clone()).ToArray(), Body.Clone(), Pool.Clone());

        public IExpression Clon() => new DeclareFunctionStatement(Name.Clone(), Args.Select(a => a.Clone()).ToArray(), Body.Clone(), Pool.Clone());

        public void Execute()
        {
            IClass function = new IClass(Name.View, new Dictionary<string, object>(), new UserFunction(Args, Body));
            Function = function;
            if (Pool is null)
                Objects.AddVariable(Name.View, function);
            else
                Pool.AddAttribute(Name.View, function);
//=> Objects.AddFunction(Name.View, new UserFunction(Args, Body));
        } 

        public object Evaluated()
        {
            Execute();
            return Function.Clone();
        }

        public override string ToString() => $"{Name} => ({string.Join("|", Args.Select(a => a.View))}) {Body};";
    }

    public sealed class ProcedureStatement : IStatement, IExpression
    {
        public IExpression Function;

        public ProcedureStatement(IExpression function) => Function = function;

        public IStatement Clone() => new ProcedureStatement(Function.Clon());

        public IExpression Clon() => new ProcedureStatement(Function.Clon());

        public void Execute() => Function.Evaluated();

        public object Evaluated() => Function.Evaluated();

        public override string ToString() => $"ВЫПОЛНИТЬ ПРЕЦЕДУРУ {Function};";
    }

    public sealed class ClearStatement : IStatement, IExpression
    {
        public void Execute() => Console.Clear();

        public object Evaluated() => "ЧИСТКА КОНСОЛИ";

        public IStatement Clone() => new ClearStatement();

        public IExpression Clon() => new ClearStatement();

        public override string ToString() => "ЧИСТКА КОНСОЛИ;";
    }

    public sealed class SleepStatement : IStatement, IExpression
    {
        public IExpression Ms;

        public SleepStatement(IExpression ms) => Ms = ms;

        public IStatement Clone() => new SleepStatement(Ms.Clon());

        public IExpression Clon() => new ClearStatement();

        public void Execute() => Thread.Sleep(Convert.ToInt32(Ms.Evaluated()));

        public object Evaluated()
        {
            int ms = Convert.ToInt32(Ms.Evaluated());
            Thread.Sleep(ms);
            return Convert.ToInt64(ms);
        }

        public override string ToString() => $"СОН({Ms})";
    }

    public sealed class ProgramStatement : IStatement, IExpression
    {
        IExpression Program;

        public ProgramStatement(IExpression program) => Program = program;

        public IStatement Clone() => new ProgramStatement(Program.Clon());

        public IExpression Clon() => new ProgramStatement(Program.Clon());

        public void Execute()
        {
            string code = Convert.ToString(Program.Evaluated());
            VovaScript2.PycOnceLoad(code, VovaScript2.Directory);
        }

        public object Evaluated()
        {
            string code = Convert.ToString(Program.Evaluated());
            try
            {
                VovaScript2.PycOnceLoad(code, VovaScript2.Directory);
            }
            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            return code;
        }

        public override string ToString() => "РУСИТЬ " + Program.ToString();
    }

    public sealed class NothingStatement : IStatement, IExpression
    { 
        public void Execute() { }

        public object Evaluated() => Objects.NOTHING;

        public IStatement Clone() => new NothingStatement();

        public IExpression Clon() => new NothingStatement();

        public override string ToString() => "НИЧЕГО"; 
    }

    public sealed class DeclareClassStatement : IStatement, IExpression
    {
        public Token ClassName;
        public Token[] Inherit;
        public IStatement Body;

        public DeclareClassStatement(Token className, Token[] inherit, IStatement body)
        {
            ClassName = className;
            Inherit = inherit;
            Body = body;
        }

        public IStatement Clone() => new DeclareClassStatement(ClassName.Clone(), Inherit, Body.Clone());

        public IExpression Clon() => new DeclareClassStatement(ClassName.Clone(), Inherit, Body.Clone());

        public void Execute()
        {
            IClass newClass = new IClass(ClassName.View, new Dictionary<string, object>());
            BlockStatement body = Body as BlockStatement;

            foreach(Token inherit in Inherit)
            {
                object parrent = Objects.GetVariable(inherit.View);
                if (parrent is IClass)
                {
                    IClass parrentClass = parrent as IClass;
                    foreach (var attr in parrentClass.Attributes)
                        newClass.AddAttribute(attr.Key, attr.Value);
                }
                else
                    throw new Exception($"<{inherit.View}> ЯВЛЯЛСЯ НЕ КЛАССОМ ИЛИ ОБЪЕКТОМ, А <{parrent}>, А СЛЕДОВАТЕЛЬНО ОТ НЕГО НЕ МОЖЕТ НАСЛЕДОВАТЬ");
            }

            foreach (IStatement statement in body.Statements)
            {
                if (statement is AssignStatement)
                {
                    AssignStatement assign = statement as AssignStatement;
                    object result = assign.Expression.Evaluated();
                    newClass.AddAttribute(assign.Variable.View, result);
                    continue;
                }
                if (statement is DeclareFunctionStatement)
                {
                    DeclareFunctionStatement method = statement as DeclareFunctionStatement;
                    method.Execute();
                    newClass.AddAttribute(method.Name.View, new IClass(method.Name.View, new Dictionary<string, object>(), new UserFunction(method.Args, method.Body)));
                    continue;
                }
                throw new Exception($"НЕДОПУСТИМОЕ ВЫРАЖЕНИЕ ДЛЯ ОБЬЯВЛЕНИЯ В КЛАССЕ: <{TypePrint.Pyc(statement)}> С ТЕЛОМ {statement}");
            }
            Objects.AddVariable(newClass.Name, newClass);
        }

        public object Evaluated()
        {
            Execute();
            return new NewObjectExpression(ClassName, new IStatement[0]);
        }

        public override string ToString() => $"КЛАСС {ClassName.View}{{{Body}}}";
    }

    public sealed class AttributeAssignStatement : IStatement, IExpression
    {
        public Token ObjName;
        public Token[] Attributes;
        public IExpression Value;
        public object Result;

        public AttributeAssignStatement(Token objName, Token[] attrs, IExpression value)
        {
            ObjName = objName;
            Attributes = attrs;
            Value = value;
        }

        public IStatement Clone() => new AttributeAssignStatement(ObjName.Clone(), Attributes.Select(a => a.Clone()).ToArray(), Value.Clon());

        public IExpression Clon() => new AttributeAssignStatement(ObjName.Clone(), Attributes.Select(a => a.Clone()).ToArray(), Value.Clon());

        public void Execute() 
        {
            ParrentAttrValue result = HelpMe.GiveMeAttrAndValue(ObjName, Attributes, Value);
            Result = result.Value;
            result.Parrent.AddAttribute(result.AttrName, result.Value);
        }

        public object Evaluated()
        {
            Execute();
            return Result is IClass ? ((IClass)Result).Clone() : Result;
        }
        
        public override string ToString() => $"{ObjName}.{PrintStatement.ListString(Attributes.Select(a => (object)a).ToList())} = {Value}";
    }

    public sealed class MethodAssignStatement : IStatement, IExpression
    {
        public Token ObjName;
        public Token[] Attributes;
        public Token[] Args;
        public IStatement Body;
        public object Result;

        public MethodAssignStatement(Token objectName, Token[] attrs, Token[] args, IStatement body)
        {
            ObjName = objectName;
            Attributes = attrs;
            Args = args;
            Body = body;
        }

        public IStatement Clone() => new MethodAssignStatement(ObjName.Clone(), Attributes.Select(a => a.Clone()).ToArray(), Args.Select(a => a.Clone()).ToArray(), Body.Clone());

        public IExpression Clon() => new MethodAssignStatement(ObjName.Clone(), Attributes.Select(a => a.Clone()).ToArray(), Args.Select(a => a.Clone()).ToArray(), Body.Clone());

        public void Execute()
        {
            ParrentAttrValue result = HelpMe.GiveMeAttrAndValue(ObjName, Attributes, new NumExpression(""));
            Result = new IClass(result.AttrName, new Dictionary<string, object>(), new UserFunction(Args, Body));
            result.Parrent.AddAttribute(result.AttrName, Result);
        }

        public object Evaluated()
        {
            Execute();
            return Result is IClass ? ((IClass)Result).Clone() : Result;
        }

        public override string ToString() => $"{ObjName}.{PrintStatement.ListString(Attributes.Select(a => (object)a).ToList())} => ({string.Join("|", Args.Select(a => a.View))}) {Body}";
    }

    public sealed class LoopStatement : IStatement, IExpression
    {
        IStatement Statement;

        public LoopStatement(IStatement statement) => Statement = statement;


        public IStatement Clone() => new LoopStatement(Statement.Clone());

        public IExpression Clon() => new LoopStatement(Statement.Clone());

        public void Execute()
        {
            while (true)
            {
                try
                {
                    Statement.Execute();
                }
                catch (BreakStatement)
                {
                    break;
                }
                catch (ContinueStatement)
                {
                    // continue by itself
                }
            }
        }

        public object Evaluated()
        {
            try
            {
                Execute();
            }

            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public override string ToString() => $"цикл: {{{Statement}}}";
    }

    public sealed class SliceAssignStatement : IStatement, IExpression
    {
        public Token ObjectName;
        public IExpression[][] Slices;
        public Token[] Attrs;
        public IExpression Slice;
        public bool Exactly;
        public bool Fill;

        public SliceAssignStatement(Token objectName, IExpression[][] slices, Token[] attrs, IExpression slice, bool exactly, bool fill, bool toNothing = false)
        {
            ObjectName = objectName;
            Slices = slices;
            Attrs = attrs;
            Slice = slice;
            Exactly = exactly;
            Fill = fill;
        }

        public IStatement Clone() => new SliceAssignStatement(ObjectName.Clone(), Slices is null ? null : Slices.Select(s => s.Select(i => i.Clon()).ToArray()).ToArray(), Attrs is null ? null : Attrs.Select(a => a.Clone()).ToArray(), Slice.Clon(), Exactly, Fill);

        public IExpression Clon() => new SliceAssignStatement(ObjectName.Clone(), Slices is null ? null : Slices.Select(s => s.Select(i => i.Clon()).ToArray()).ToArray(), Attrs is null ? null : Attrs.Select(a => a.Clone()).ToArray(), Slice.Clon(), Exactly, Fill);

        public void Execute()
        {
            object taked;
            IClass toSave = null;
            string attrName = "";
            object got;

            if (Slices is null)
            {
                if (Attrs is null)
                    new AssignStatement(ObjectName, Slice).Execute();
                else
                    new AttributeAssignStatement(ObjectName, Attrs, Slice).Execute();
                return;
            }

            if (Attrs is null)
            {
                taked = Objects.GetVariable(ObjectName.View);
                got = Slice.Evaluated();
            }
            else
            {
                ParrentAttrValue result = HelpMe.GiveMeAttrAndValue(ObjectName, Attrs, Slice);
                toSave = result.Parrent;
                attrName = result.AttrName;
                got = result.Value;
                taked = toSave.GetAttribute(attrName);
            }

            IndecesValue resulted = HelpMe.GiveMeIndecesAndValue(ObjectName, Slices, taked);
            if (resulted.WasString)
            {
                List<int> assignIndecex = resulted.AssignIndeces;
                List<object> value = resulted.Value;

                object ret = HelpMe.GiveMeRetOfListAndIndeces(got, assignIndecex, value, Slices, Exactly, Fill);
                if (toSave is null)
                    Objects.AddVariable(ObjectName.View, ret);
                else
                    toSave.AddAttribute(attrName, ret);
                return;
            }


            throw new Exception($"{ObjectName.View}" + (Attrs is null ? "" : string.Join(".", Attrs.Select(a => a.View).ToArray())) + $"НЕ БЫЛ ЛИСТОМ ИЛИ СТРОКОЙ, А <{got}>");
        }

        public object Evaluated()
        {
            Execute();
            throw new Exception("asdfasdfasdfaf");
        }

        public override string ToString() => $"{ObjectName}" + (Attrs is null ? "" : $".{PrintStatement.ListString(Attrs.Select(a => (object)a).ToList())})") + $" = {Slice};";
    }

    public sealed class ImportStatement : IStatement, IExpression
    {
        int Dots;
        Token[] Path;
        object Result = "";

        public ImportStatement(int dots, Token[] path)
        {
            Dots = dots;
            Path = path;
        }

        public IStatement Clone() => new ImportStatement(Dots, Path);

        public IExpression Clon() => new ImportStatement(Dots, Path);

        public void Execute()
        {
            string dir = VovaScript2.Directory;
            List<string> folds = dir.Split('\\').ToList();
            folds = folds.Take(folds.Count - 1 - Dots).ToList();
            folds.AddRange(Path.Select(p => p.View));
            string filename = string.Join("\\", folds) + ".pyclan";

            if (File.Exists(filename))
            {
                bool timeWas = VovaScript2.TimePrint;
                VovaScript2.TimePrint = false;
                string code = string.Join(" ", File.ReadAllLines(filename));
                VovaScript2.PycOnceLoad(code, dir);
                VovaScript2.TimePrint = timeWas;
                Result = code;
            }
            else
                throw new Exception("НЕ СУЩЕСТВУЮЦИЙ МОДУЛЬ В " + filename);
        }

        public object Evaluated()
        {
            Execute();
            return Result;
        }

        public override string ToString() => $"ВКЛЮЧИТЬ {string.Join(".", Path.Select(p => p.View))}";
    }

    public sealed class ThrowStatement : IStatement, IExpression
    {
        public IExpression Message;
        public object Result;

        public ThrowStatement(IExpression message)
        {
            Message = message;
        }

        public void Execute() 
        {
            Result = HelpMe.GiveMeSafeStr(Message.Evaluated());
            throw new Exception(Result as string);
        }

        public object Evaluated()
        {
            Execute();
            return Result; // its have no meaning at all but well will it be for the sake of IExpression i dunno wry
        }

        public IStatement Clone() => new ThrowStatement(Message.Clon());

        public IExpression Clon() => new ThrowStatement(Message.Clon());

        public override string ToString() => $"БРОСЬ {Message}";
    }

    public sealed class TryCatchStatement : IStatement, IExpression
    {
        public IStatement TryBlock;
        public Token To;
        public IStatement CatchBlock;

        public TryCatchStatement(IStatement tryBlock, Token to, IStatement catchBlock)
        {
            TryBlock = tryBlock;
            To = to;
            CatchBlock = catchBlock;
        }

        public void Execute()
        {
            try
            {
                TryBlock.Execute();
            }
            catch(Exception e)
            {
                if (To != null)
                    Objects.AddVariable(To.View, e.Message);
                CatchBlock.Execute();
            }
        }

        public object Evaluated()
        {
            try
            {
                Execute();
            }
            catch (ReturnStatement result)
            {
                return result.GetResult();
            }
            throw new Exception($"ЕСЛИ ИСПОЛЬЗОВАТЬ ТАК СТРУКТУРУ <{this}> ТО НАДО ЧТО-ТО ВЕРНУТЬ");
        }

        public IStatement Clone() => new TryCatchStatement(TryBlock.Clone(), To is null ? null : To.Clone(), CatchBlock.Clone());

        public IExpression Clon() => new TryCatchStatement(TryBlock.Clone(), To is null ? null : To.Clone(), CatchBlock.Clone());

        public override string ToString() => "ПОПРОБОВАТЬ {" + TryBlock.ToString() + "} ПОЙМАТЬ" + (To is null ? "" : To.ToString()) + " {" + CatchBlock.ToString() + "}";
    }

    public sealed class WhereFullAssignStatement: IStatement, IExpression
    {
        public FullNodeToAssign Node;
        public Token Operation;
        public IExpression Assigned;
        public bool Exactly;
        public bool Fill;
        public object Result;

        public WhereFullAssignStatement(FullNodeToAssign node, Token operation, IExpression assigned, bool exactly, bool fill)
        {
            Node = node;
            Operation = operation;
            Assigned = assigned;
            Exactly = exactly;
            Fill = fill;
        }

        public IExpression Clon() => new WhereFullAssignStatement(Node.Clone(), Operation.Clone(), Assigned.Clon(), Exactly, Fill);

        public IStatement Clone() => new WhereFullAssignStatement(Node.Clone(), Operation.Clone(), Assigned.Clon(), Exactly, Fill);

        public void Execute()
        {
            if (Node.Parts.Length == 0)
            {
                if (Operation.Type == TokenType.DO_EQUAL)
                {
                    Result = new AssignStatement(Node.ObjName, Assigned).Evaluated();
                    return;
                }
                Token op = new Token() { Location = new Location(-1, -1) };
                switch (Operation.Type)
                {
                    case TokenType.PLUSEQ:
                        op.Type = TokenType.PLUS;
                        op.View = "+";
                        break;
                    case TokenType.MINUSEQ:
                        op.Type = TokenType.MINUS;
                        op.View = "-";
                        break;
                    case TokenType.MULEQ:
                        op.Type = TokenType.MULTIPLICATION;
                        op.View = "*";
                        break;
                    case TokenType.DIVEQ:
                        op.Type = TokenType.DIVISION;
                        op.View = "/";
                        break;
                    default:
                        break;
                }
                Result = new AssignStatement(Node.ObjName, new BinExpression(new VariableExpression(Node.ObjName), op, Assigned)).Evaluated();
                return;
            }

            Result = Assigned.Evaluated();
            object root = Objects.GetVariable(Node.ObjName.View);
            IClass parrent = null;
            string attrName = "";
            object obj = null;
            List<object> listed = null;
            int[] indecesToAssign = null;

            if (Node.Parts[0] is Token)
            {
                if (root is IClass)
                    parrent = root as IClass;
                else
                    throw new Exception($"<{Node.ObjName.View}> ОЖИДАЛСЯ БЫТЬ ОБЪЕКТОМ КЛАССА, НО БЫЛ <{root}>");
            }
            else if (root is List<object> || root is string)
                listed = SliceExpression.Obj2List(root);
            else
                throw new Exception($"<{Node.ObjName.View}> ОЖИДАЛСЯ БЫТЬ ОБЪЕКТОМ ЛИСТОМ ИЛИ СТРОКОЙ, НО БЫЛ <{root}>");

            obj = parrent is null ? (object)listed : parrent;

            foreach (object part in Node.Parts)
            {
                if (part is Token)
                {
                    if (obj is IClass)
                        parrent = obj as IClass;
                    else
                        throw new Exception($"<{obj}> ОКАЗАЛСЯ НЕ ОБЪЕКТОМ, А <{obj}> ПРИ ПОПЫТКИ ВЗЯТЬ ИЗ НЕГО <{(part as Token).View}>");
                    attrName = (part as Token).View;
                    obj = parrent.GetAttribute(attrName);
                    continue;
                }
                if (part is IExpression[])
                {
                    bool wasString = obj is string;
                    if (obj is List<object>)
                        listed = obj as List<object>;
                    else if (wasString)
                        listed = SliceExpression.Obj2List(obj);
                    else
                        throw new Exception($"<{(part as Token).View}> ОКАЗАЛСЯ НЕ ЛИСТОМ ИЛИ СТРОКОЙ, А <{obj}>");

                    ListAndIndeces observedList = HelpMe.GiveMeListAndIndeces(obj, indecesToAssign, part as IExpression[]);
                    if (observedList.Indeces.Length == 0)
                        return;

                    //parrent = null;
                    if (observedList.Indeces.Length == 1)
                    {
                        try
                        {
                            if (wasString)
                                obj = HelpMe.GiveMeSafeStr(observedList.List[observedList.Indeces[0]]);
                            else
                                obj = observedList.List[observedList.Indeces[0]];
                        }
                        catch
                        {
                            throw new Exception($"ВЫШЕЛ ЗА РАМКИ ЛИСТА <{HelpMe.GiveMeSafeStr(observedList.List)}> С ИНДЕКСОМ <{observedList.Indeces[0]}>");
                        }
                        indecesToAssign = observedList.Indeces;
                        continue;
                    }

                    obj = wasString ? (object)string.Join("", observedList.List) : observedList.List;
                    indecesToAssign = observedList.Indeces;
                }
            }
            // сначала надо получить саму вещь для назначения и потоам еще и всякие = += -=
            // obj который либо объект и имеет parrent 
            // либо лист и имеет индексы
            if (Operation.Type == TokenType.DO_EQUAL)
            {
                if (obj is IClass)
                {
                    (obj as IClass).AddAttribute(attrName, Assigned.Evaluated());
                    return;
                }
                //if (obj is List<object> || obj is string)
                //{
                    bool wasString = obj is string;
                    obj = HelpMe.GiveMeRetOfListAndIndeces(Assigned.Evaluated(), indecesToAssign.ToList(), SliceExpression.Obj2List(obj), null, Exactly, Fill);
                    parrent.AddAttribute(attrName, wasString ? string.Join("", obj as List<object>) : obj);
                    return;
               // }
                Console.WriteLine(obj);
                throw new Exception("ЭТО НЕ ДОЛЖНО ТАК БЫТЬ");
            }
            else
            {
                throw new Exception("面倒");
                // параша с += -= *= /=
            }
        }

        public object Evaluated()
        {
            Execute();
            return Result;
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
