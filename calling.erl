-module(calling).
-export([childThread/3,messagePass/2,individualReceiver/2]).

childThread(Sender,ReceiverList,Mid) ->
	individualReceiver(Sender,ReceiverList),
	messagePass(Sender,Mid).



individualReceiver(Sender, ReceiverList) ->
	lists:foreach(fun(Recv) ->
		timer:sleep(rand:uniform(100)),
		{_,_,Time} = erlang:now(),
		R_id = whereis(Recv),
		R_id ! {Sender, Time}
		end, ReceiverList).

messagePass(Sender,Mid) ->
	receive
		{Sender_Name, TimeStamp} ->

			IntroMessage = "received intro message from",
			Mid ! { Sender,Sender_Name,IntroMessage,TimeStamp,introMessage},
			Sender_Id = whereis(Sender_Name),
			Sender_Id ! {Sender,TimeStamp,replyMessage},
			messagePass(Sender, Mid);
		{Sender_Name,TimeStamp,replyMessage} ->	
			ReplyMessage = "received reply message from",
			Mid ! {Sender,Sender_Name,ReplyMessage,TimeStamp,replyMessage},
			messagePass(Sender, Mid)
	
	after(5000) ->
		Mid ! {Sender,terminatingCondition},
		exit(kill)
	
	end.