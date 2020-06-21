-module(exchange).
-export([start/0,printData/1,registerProcess/1,printMessages/0]).

start() ->
	{ok, DataSet} = file:consult("calls.txt"),
	printData(DataSet),
	io:format("~n"),
	registerProcess(DataSet),
	printMessages().

printData(DataSet) ->
	lists:foreach(fun(Tuple) ->
		{Sender,ReceiverList} = Tuple,
		io:format("~w: ~w ~n",[Sender,ReceiverList])
	end,DataSet).

registerProcess(DataSet) ->
	lists:foreach(fun (Tuple) ->
		{Sender,ReceiverList} = Tuple,
		Pid = spawn(calling, childThread,[Sender,ReceiverList,self()]),
		register(Sender,Pid)
	end, DataSet).

printMessages() ->
	receive 
		
		{Receiver_Name,Sender_Name,Reply_Message,TimeStamp, replyMessage} ->
		io:fwrite("~w ~s ~w [~w] ~n", [Receiver_Name,Reply_Message,Sender_Name,TimeStamp]),
		printMessages();
		{Receiver_Name,Sender_Name,IntroMessage,TimeStamp, introMessage} ->
		io:fwrite("~w ~s ~w [~w] ~n",[Receiver_Name,IntroMessage,Sender_Name,TimeStamp]),
		printMessages();
		{Sender_Process_Name, terminatingCondition} ->
		io:fwrite("~n"),
		io:fwrite("Process ~w has received no calls for 5 seconds, ending... ~n",[Sender_Process_Name]),
		printMessages()
	after(10000) ->
		io:fwrite("~nMaster has not received no calls for 10 seconds, ending...~n")
		
	end.



%% References.
% https://erlang.org/doc/getting_started/conc_prog.html
% https://www.tutorialspoint.com/erlang/erlang_maps.htm
% https://www.tutorialspoint.com/erlang/erlang_concurrency.htm
% https://erlang.org/doc/programming_examples/funs.html
% https://erlang.org/doc/reference_manual/processes.html
