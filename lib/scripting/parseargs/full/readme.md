# Documentation

"parseargs" has been designed to serve as a universal automation tool for parsing arguments in both bash function and bash 
script context. It provides a flexible interface that makes it useable in case of a simple a few-lines-long library functions 
as well as in the extensive multi-tool scripts requiring automated validation of arguments and automated generation of the 
'usage' message.

Module is designed around variables' references (declare -n) introduced in bash 4.3. Public API contains a single high level
function @fun `parseargs` and three low level functions - @fun `parsepargs`, @fun `parseopts` and @fun `parsenvs` - that are 
components of the @fun `parseargs` function as well as a set of aliases that establish a helper interface for calling thses
functions in various environments. In the simplest form @fun `parseargs` takes two arguments - @p args containing name of the
array holding arguments to be parsed and @p pargs (from 'positional arguments') containing name of the output array where the
parsed positional arguments should be stored - and copies content of the array named @p args into the array named @p pargs. 
Although in this form it is not the most usefull tool, this is the simplest definition of what 'to parse arguments' means.

The module incorporates also some helper methods that can turn out to be usefull when playing with arguments' parsing in bash.

## Arguments' description

To let user describe arguments of their functions and scripts in a more declarative - and so, in opitnion of the author, more 
readable - form, "parseargs" introduces a **Unified Bash Arguments Description** format (UBAD for short). If your are the a newbie
in the bash world, don't bother nomenclature. UBAD is just a fancy name gathering two concpets:

    (1) definition of the data format (called 'UBAD table') describing an argument that in other languages would be called 
        a 'dictionary' or a 'structure' with the strictly defined keys or fields
    (2) set of rules describing meaning of it's fields in various contexts

In general the structure of the UBAD table (1) is following:

<code>

    declare -A ubad_table=(
        [format]=STR
        [name]=STR
        [type]=STR
        [defaut]=STR_OR_INT
        [variants]=LIST
        [range]=PAIR
        [help]=STR
    )

</code>

Most of fields of the structure (or using bash nomenclature - this "hash table") are optional and although you can probably 
figure out their meaning, their properties are extensivey described below. UBAD descriptors are gathered into arrays
(UBAD lists) collecting definitions for arguments of the given _type_ (see below)

    # Definition of arguments' descriptors
    declare -A arga_description=(...)
    declare -A argb_description=(...)
    declare -A argc_description=(...)

    # Compiled description of all arguments of the given type
    declare -a pargs_descriptions=( 
        arga_description
        argb_description
        argc_description
    )

## Types of arguments

Before one can talk about UBAD tables, they need to descibe context of the talk (2). UBAD divides arguments into three 
categories:
    
    1) positional arguments (pargs) - these are the most straighforward form of arguments. We are using them all the time
    when calling various standard Linux tools. For example in `echo "Hello world"` the "Hello world" string is a positional
    argument. Positional arguments are indexed with integer numbers starting from 1 (in bash, the 0 index is usually 
    reserved for name of the program; as this is not what programmers like the most, "parseargs" tends to aim this issue 
    too). In many scenarios positional arguments are also 'obligatory' arguments, but it is not always the case. Sometimes
    (okay, maybe more 'times' than 'some') functions and scripts can take undefined number of arguments. We refer to this
    as a 'variadic argument list'. In such cases meaning of these positional arguments is common (to some extend) and so 
    are potential resitrictions that the function/script puts on them. Conceptually 'positional arguments' refer to two 
    types of arguments:
    
            I ) required arguments
            II ) unnamed optional arguments
    
    Although it seems to narrow the full meaning of this term, author's expirience shows that it is usually 'enough'
    to reason about this type of arguments. These arguments are passed to the function/script explicitly and they cannot
    begin with a hyphenh. Formally UBAD divides positional arguments into three sets:
    
            I ) positional arguments (pargs) - all positional arguments
            II ) named positional arguments (nargs) - positional arguments that have names defined by the module's client
                code; they always precede unnamed positional arguments
            III ) unnamed positional arguments (uargs) - positional arguments that hasve NOT names defined by the module's
                client code
    
    Both 'nargs' and 'uargs' are subsequences of 'pargs' where 'nargs' - if defined - always share the first argument
    with 'pargs' and 'uargs' - if defined - shares the last argument with 'pargs'. 'nargs' and 'uargs' summs up (in the
    sens of sets' summation) into the 'pargs'
    
    2) optional arguments (opts) - these are optional arguments par excellence, i.e. thay may or may not be passed to the
    function/script depending on the user's requirements. Optional arguments are also passed explicitly to the 
    function/script and in contrast to positional arguments always begin with a hyphenh. "parseargs" uses standard GNU
    `getopt` convention for defining optional arguments (in fact it uses `getopt` underthehood)
    
    3) environmental arguments (envs) - as we all know bash has very poor namespacing capabilities. This means that variables
    from the caller's context are visible in the context of the called function unless they are explicitly hidden by the
    definition with the matching name in the function's body. It is often a pain in the neck for programmers working
    with more robust languages than bash scripting language. However there are situatuions where such a feature may be
    taken as an advantage. An example is a "logging" module from the bash-utils project. It's `log` function produces
    an additional context information (which is in fact just a string describing from what part of the system the log
    comes from) when the LOG_CONTEXT variable is defined. As the `log` function cannot tell the difference whether the 
    variable has been declared globally or locally in the upper context, this mechanism provides an easy way to unify
    log context for the whole (or even part!) of the call stack. Thanks to it one can avoid tedious implementation and 
    copypasting of something like --log-context option in every function that can (directly or indirectly) produce some 
    logs. As such a short cut can be handy from time to time, the "parseargs" module defines variables _implicitly_
    passed to the function/script as the third type of arguments. Be carefull though, 'environmental arguments' are NOT
    the same as the Linux environmental variables!
    
@fun `parseopts` function uses three types of UBAD lists - 'args-definitions', 'opts-definitions' and 'envs-definitions' - to 
acquire arguments' descriptions. Order of the UBAD tables in the 'args-definitions' list determines order of described 
positional arguments. Results of the parsing routine are written into three hash arrays and two array:

    1) pargs - array of all parsed positional arguments
    2) nargs - hash array of parsed named positional arguments
    2) uargs - array of parsed unnamed positional arguments
    2) opts  - hash array of parsed optional arguments
    2) envs  - hash array of parsed environmental arguments

## UBAD Table

Having described types of argument distinguished by the module we can move to the description of the structure of the UBAD 
table. Underlying section tends to describe subsequent fields in a way that is exhaustive for the topic and hopefully not for
the user :)

[format] (optional/required)

    This field wears two hats. First of all, it describes WHAT should be parsed. Meaning of 'what should be parsed' differs
    from argument's type to type and so are requirements for this format, hence their descriptions are divided into threee
    categories.

    --> Positional arguments (optional)
            
            For positional arguments this field - if given - takes one of three forms: 'NAME', 'NAME[n]' or 'NAME...',
            where 'NAME' is any (preferably human-readable) string consisting of alphanumerical characters and unerscores
            (may be an empty string). The first forms describes, that the UBAD table refers to a single positional argument. 
            The second form describes n subsequent positional arguments. The last form refers to a variadic list of arguments
            (note: UBAD table using 'NAME...' format - if used - should be the last element of the UBAD list descibing 
            positional argument. Further entries will be ommitted by the `parseargs` function)

            If this field is not given, a single positional argument is assumed.

    --> Optional arguments (required)

            For optional arguments this field holds a string representing a '|'-separated list of standard GNU options'
            identifiers. For more informations refer to `getopt`

    --> Environmental arguments (required)

            For environmental arguments this field contains a name of the variable to be parsed

    The secod function of the [format] field is to provide a human-readable name of the argument for auto-generated 'usage'
    message. For positional arguments - for which this field is optional - if no field is given or when NAME is an empty
    string the default name 'ARGx' is used, where 'x' is an index of the UBAD table in the UBAD list of positional argument
    (indexed from 1)

[name] (optional/required)

    Name of the key under which the argument should be parsed into the destination hash array (nargs/opts/envs)

        --> Positional arguments (optional)

            For positional arguments, if this field is not defined, the parsed argument will be written into
            the 'uargs' array and not into the 'nargs' hash array. If defined, it will correspond to the key in the
            'nargs' hash array which the parsed option will be stored under.

            If [name] field is given, and the [format] field describes multiple arguments ('NAME[n]' or 'NAME...' format)
            names of keys in the 'nargs' hash array will be produces by appending index of the argument (inside the group)
            to the value of the [name] field

        --> Optional arguments & Environmental arguments (required)

            For optionals and environmental arguments this field is required and defines name of the key in the 
            'opts' and 'envs' hash tables respectively that the parsed argument will be stored into.

[type] (optional)

    Type of the argument. This may be one of:

        s|string) argument holding a string
        i|integer) argument holding an integer
        p|path) argument holding a path
        f|flag) argument holding a flag (not applicable for positional arguments)

    The default type is 'string'. Type of the argument may be used for automatic verification (only for integers and paths).

[defaut] (optional, meaningless for flag arguments)

    The default value of the argument if it is not parsed. 

[variants] (optional, meaningless for flag arguments)

    '|'-separated list of valid values that the argument may take. By default every element of the list if trimmed (edge 
    whitespace characters are removed) to enable user declare variants like this - 'var1 | var2 | var3' - instead of like this
    'var1|var2|var3'. This behaviour may be changed by setting corresponding switch of the `parseargs` function

    Variants may contain regex expressions (supported by the =~ operator) taken into '[...]'. '[]' characters can be escaped 
    with a leading backslash (note: this functionality is a goal, but it is not implemented yet)

[range] (optional, meaningless for flag arguments)

    Colon-separated pair of values defining 'MIN:MAX' range for the argument. For string-typed and path-typed arguments the
    lexicalographical comparison is used. This field is overwritten by the [variants] field, if given

[help] (optional)

    Human-readable description of the argument used for automatic generation of the 'usage' message