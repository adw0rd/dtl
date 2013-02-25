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

%% @doc Tests for the production lexer.
-module(dtl_lexer_tests).

-include("dtl_compiler.hrl").

-include_lib("eunit/include/eunit.hrl").

setup() ->
    application:set_env(dtl, debug, false).

text_token_test_() ->
    {setup, fun setup/0,
     [?_assertEqual([{?TOKEN_TEXT, <<"Hello">>}], dtl_lexer:tokenize(<<"Hello">>))]}.

block_tag_and_text_test_() ->
    {setup, fun setup/0,
     [?_assertEqual([{?TOKEN_TEXT, <<" ">>},
                     {?TOKEN_BLOCK, <<"block oink">>},
                     {?TOKEN_TEXT, <<" Content ">>},
                     {?TOKEN_BLOCK, <<"endblock">>},
                     {?TOKEN_TEXT, <<" ">>}],
                    dtl_lexer:tokenize(" {% block oink %} Content {% endblock %} "))]}.