#!/usr/bin/env escript
%% Copyright (c) 2013- Thomas Allen <thomas@oinksoft.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining
%% a copy of this software and associated documentation files (the
%% "Software"), to deal in the Software without restriction, including
%% without limitation the rights to use, copy, modify, merge, publish,
%% distribute, sublicense, and/or sell copies of the Software, and to
%% permit persons to whom the Software is furnished to do so, subject to
%% the following conditions:
%%
%% The above copyright notice and this permission notice shall be
%% included in all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
%% BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
%% ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
%% CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.

%% @doc EDoc generation script.
main(_Args) ->
    {ok, Cwd} = file:get_cwd(),
    Files = lists:filter(fun (Filename) ->
        string:str(Filename, "tests.erl") =:= 0
    end, filelib:wildcard(filename:join([Cwd, "src/*.erl"]))),
    code:add_patha(filename:join([Cwd, "ebin"])),
    Docs = filename:join([Cwd, "doc"]),
    ok = edoc:files(Files, [{dir, Docs},
                            {new, true},
                            {preprocess, true},
                            {includes, ["include"]}]).
