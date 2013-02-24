#Django Template Language

A full-featured port of the Django template engine to Erlang.

**NOTE: The usage described in `3. Basic Usage' is still a work in
  progress, and dtl:render() remains something of a stub.**


##Table of Contents

1. [Introduction](#1-introduction)
2. [Installation](#2-installation)
3. [Configuration](#3-configuration)
4. [Basic Usage](#4-basic-usage)
5. [Syntax](#5-syntax)
6. [Context and Context Processors](#6-context-and-context-processors)
7. [Loader Modules](#7-loader-modules)
8. [Custom Filters](#8-custom-filters)
9. [Custom Tags](#9-custom-tags)
10. [Troubleshooting](#10-troubleshooting)
11. [FAQ](#11-faq)
12. [Support/Getting Help](#12-supportgetting-help)
13. [API Documentation](#13-api-documentation)
14. [Roadmap](#14-roadmap)


##1. Introduction

This project is an effort to fully implement the Django template engine
in Erlang. I hope to create a feature-complete port, using the same data
types and striving for parity with the Python API and the base
filter/tag set included in Django.


##2. Installation

To install the latest version, add this to your dependency list in
rebar.config:

    {dtl, ".*", {git, "git://github.com/oinksoft/dtl.git", "master"}}

and run `rebar get-deps` and `rebar compile`. Refer to the [rebar
documentation](https://github.com/basho/rebar) if this is unclear.

##3. Configuration

The following are the configuration keys for the `dtl` app, their
expected types, and any default values:

|Key                  |Type                 |Default                           |
|---------------------|---------------------|----------------------------------|
|apps                 |`[atom()]`           |`[]`                              |
|debug                |`boolean()`          |`false`                           |
|context\_processors  |`[{atom(), atom()}]` |`[]`                              |
|template\_dirs       |`[list()]`           |`[]`                              |
|template\_loaders    |`[atom()]`           |`[dtl_fs_loader, dtl_apps_loader]`|

**apps**: A list of apps that the `dtl_apps_loader` should use.

**debug**: Set `true` to allow more detailed debugging output in
    rendered templates, `false` otherwise.

**template\_dirs**: A list of arbitrary file system locations where
    `dtl_fs_loader` will look for templates.

**template\_loaders**:
    A list of modules implementing the `dtl_loader` behaviour. During
    template lookup, they will be tried in the order specified.


##4. Basic usage

See "5. Context" for information on setting context variables in your
templates, and "6. Loader Modules" for information on where to store
your template files.

Render a template:

    {ok, Html} = dtl:render("index.html", [
        {title, "The World Wide Web"},
        {visitor_count, 12}
    ]).

Create a template from a string, create a plain context with one item
set, and render it:
    
    Source = "My name is {{ name }}.",
    {ok, Tpl} = dtl_template:new(Source),
    Ctx = dtl_context:new([
        {name, "Thomas"}
    ]),
    {ok, <<"My name is Thomas">>} = dtl_template:render(Tpl, Ctx).

Find a template and render it:

    Tpl = dtl_loader:get_template("index.html"),
    {ok, Html} = dtl_template:render(Tpl),
    %% ...

Render the first of several found templates:

    Tpl = dtl_loader:select_template(["index.html", "index.htm"]),
    {ok, Html} = dtl_template:render(Tpl),
    %% ...


##5. Syntax

Template syntax is identical to Django template syntax. Please report
any observable differences.

    https://docs.djangoproject.com/en/dev/topics/templates/


##6. Context and Context Processors

Contexts are the primary means of transmitting data from application
code to Django templates. Any value that is accessible on a context
will be accessible in any template into which the context is loaded:

    Ctx = dtl_context:new([
        {foo, "Foo"},
        {bar, "Bar"}
    ]),
    {ok, Bin} = dtl:render(Tpl, Ctx).


###6.1. Context Processors

A user may specify a list of {Mod, Fun} tuples which will be called, in
order, when initializing a new context. Each function should return a
property list. Here is an example context processor:

    process_time() ->
        Time = calendar:local_time(),
        [{Year, Month, Day}, {Hours, Minutes, Seconds}] = Time,
        [{date, io_lib:format("~p-~p-~p", [Year, Month, Day])},
         {time, io_lib:format("~p:~p:~p", [Hours, Minutes, Seconds])}].

Context processors are specified in application config.

    application:set_env(dtl, context_processors, [{my_app, process_time}]).

Now, a template could access `time` and `date` variables.


##7. Loader Modules

DTL comes with two template loader modules, which are described here:

**dtl\_fs\_loader**: This loader tries each of the configured
    `template_dirs`, in order, to see if the named template exists in
    one of them. Only templates contained in one of these directories
    will be found.

**dtl\_apps\_loader**: This loader searches in "templates" in the "priv"
    directory of each app specified with the `apps` configuration
    option.  That is, "index.html" would be searched for at
    foo/priv/templates/index.html if `foo` were included in the `apps`
    configuration option.

You can also implement your own loaders. Here is a loader that tries to
copy a template from a web service (!):

    -module(http_loader).
    -behaviour(dtl_loader).

    -define(BASE_URL, "http://example.com/?img_name=").

    -export([is_usable/0,
             load_template_source/1,
             load_template_source/2]).

    %% A loader must implement is_usable/0. This callback is so that
    %% loaders that are only useful in certain environments (say, a
    %% memcached-backed loader) are not used.
    %%
    %% For instance, this function could test to see if ?BASE_URL's host
    %% is reachable.
    is_usable() -> true.

    %% A loader must implement load_template_source/1 and
    %% load_template_source/2. This is to match the Django API, where a
    %% `dirs' argument must be accepted even for loaders that are not
    %% concerned with this detail.
    %%
    %% This function should return a {ok, Content, DisplayName} triple
    %% where Content is the template string and DisplayName is a name
    %% for the found template, which will be used in debugging outputs.
    %%
    %% It should return {error, not_found} if the template is not found.
    %% Any other error return will immediately halt the lookup process.
    load_template_source(Name) -> load_template_source(Name, []).
    load_template_source(Name, _Dirs) ->
        %% Assume our application has already started `inets'.
        Url = ?BASE_URL ++ Name,
        %% Anything other than a 200 response is "not found".
        case httpc:request(Url) of
            {ok, {_Proto, 200, _Msg}, _Headers, Body} ->
                {ok, Body, Url};
            _ -> {error, not_found};
        end.


##8. Custom Filters

Empty.


##9. Custom Tags

Empty.


##9.1. Simple Tags

Empty.


##9.2. Complex Tags

Empty.


##10. Troubleshooting

Empty.


##11. FAQ

Empty.


##12. Support/Getting Help

Empty.


##13. API Documentation

API functions are all documented in the source code, formatted
documentation is a work in progress.


##14. Roadmap

* Base lexer and parser.
* Node/NodeList rendering, API.
* Debug lexer and parser.
* Tag interfaces.
* Filter interfaces.
* Library management.
* Base Django tags and filters.

