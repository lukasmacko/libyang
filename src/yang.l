/**
 * @file yang.l
 * @author Pavol Vican
 * @brief YANG parser for libyang (flex grammar)
 *
 * Copyright (c) 2015 CESNET, z.s.p.o.
 *
 * This source code is licensed under BSD 3-Clause License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://opensource.org/licenses/BSD-3-Clause
 */

%option noyywrap nounput noinput reentrant bison-bridge bison-locations

%{
#include "parser_yang.h"
#include "parser_yang_bis.h"

#define YY_USER_ACTION yylloc->first_column = yylloc->last_column +1;\
                       yylloc->last_column = yylloc->first_column + yyleng - 1;
%}
%x COMMENT1
%x COMMENT2
%x PATH
%x DOUBLEQUOTES
%%
 int tab_count = 0;
 int size_str = 0;
 int column = 0;
 char *str = NULL;
 int _state = YY_START;

"/*" {_state = YY_START; BEGIN COMMENT1; }
<COMMENT1>.  |
<COMMENT1>\n 
<COMMENT1>"*/" {BEGIN _state; }
"//" {_state = YY_START; BEGIN COMMENT2;}
<COMMENT2>. 
<COMMENT2>\n |
<COMMENT2>\r\n {BEGIN _state; return EOL; }
"anyxml" { return ANYXML_KEYWORD; }
"argument" { return ARGUMENT_KEYWORD; }
"augment" { BEGIN PATH; return AUGMENT_KEYWORD; }
"base" { return BASE_KEYWORD; }
"belongs-to" { return BELONGS_TO_KEYWORD; }
"bit" { return BIT_KEYWORD; }
"case" { return CASE_KEYWORD; }
"choice" { return CHOICE_KEYWORD; }
"config" { return CONFIG_KEYWORD; }
"contact" { return CONTACT_KEYWORD; }
"container" { return CONTAINER_KEYWORD; }
"default" { return DEFAULT_KEYWORD; }
"description" { return DESCRIPTION_KEYWORD; }
"enum" { return ENUM_KEYWORD; }
"error-app-tag" { return ERROR_APP_TAG_KEYWORD; }
"error-message" { return ERROR_MESSAGE_KEYWORD; }
"extension" { return EXTENSION_KEYWORD; }
"deviation" { BEGIN PATH; return DEVIATION_KEYWORD; }
"deviate" { return DEVIATE_KEYWORD; }
"feature" { return FEATURE_KEYWORD; }
"fraction-digits" { return FRACTION_DIGITS_KEYWORD; }
"grouping" { return GROUPING_KEYWORD; }
"identity" { return IDENTITY_KEYWORD; }
"if-feature" { return IF_FEATURE_KEYWORD; }
"import" { return IMPORT_KEYWORD; }
"include" { return INCLUDE_KEYWORD; }
"input" { return INPUT_KEYWORD; }
"key" { return KEY_KEYWORD; }
"leaf" { return LEAF_KEYWORD; }
"leaf-list" { return LEAF_LIST_KEYWORD; }
"length" { return LENGTH_KEYWORD; }
"list" { return LIST_KEYWORD; }
"mandatory" { return MANDATORY_KEYWORD; }
"max-elements" { return MAX_ELEMENTS_KEYWORD; }
"min-elements" { return MIN_ELEMENTS_KEYWORD; }
"module" { return MODULE_KEYWORD; }
"must" { return MUST_KEYWORD; }
"namespace" { return NAMESPACE_KEYWORD; }
"notification" { return NOTIFICATION_KEYWORD; }
"ordered-by" { return ORDERED_BY_KEYWORD; }
"organization" { return ORGANIZATION_KEYWORD; }
"output" { return OUTPUT_KEYWORD; }
"path" { BEGIN PATH; return PATH_KEYWORD; }
"pattern" { return PATTERN_KEYWORD; }
"position" { return POSITION_KEYWORD; }
"prefix" { return PREFIX_KEYWORD; }
"presence" { return PRESENCE_KEYWORD; }
"range" { return RANGE_KEYWORD; }
"reference" { return REFERENCE_KEYWORD; }
"refine" { BEGIN PATH; return REFINE_KEYWORD; }
"require-instance" { return REQUIRE_INSTANCE_KEYWORD; }
"revision" { return REVISION_KEYWORD; }
"revision-date" { return REVISION_DATE_KEYWORD; }
"rpc" { return RPC_KEYWORD; }
"status" { return STATUS_KEYWORD; }
"submodule" { return SUBMODULE_KEYWORD; }
"type" { return TYPE_KEYWORD; }
"typedef" { return TYPEDEF_KEYWORD; }
"unique" { BEGIN PATH; return UNIQUE_KEYWORD; }
"units" { return UNITS_KEYWORD; }
"uses" { return USES_KEYWORD; }
"value" { return VALUE_KEYWORD; }
"when" { return WHEN_KEYWORD; }
"yang-version" { return YANG_VERSION_KEYWORD; }
"yin-element" { return YIN_ELEMENT_KEYWORD; }
"add" { return ADD_KEYWORD; }
"current" { return CURRENT_KEYWORD; }
<PATH>"current" { return CURRENT_KEYWORD; }
"delete" { return DELETE_KEYWORD; }
"deprecated" { return DEPRECATED_KEYWORD; }
"false" { return FALSE_KEYWORD; }
"not-supported" { return NOT_SUPPORTED_KEYWORD; }
"obsolete" { return OBSOLETE_KEYWORD; }
"replace" { return REPLACE_KEYWORD; }
"system" { return SYSTEM_KEYWORD; }
"true" { return TRUE_KEYWORD; }
"unbounded" { return UNBOUNDED_KEYWORD; }
"user" { return USER_KEYWORD; }
"action" {return ACTION_KEYWORD; }
"modifier" {return MODIFIER_KEYWORD; }
"anydata" {return ANYDATA_KEYWORD; }
"{" |
"}" |
";" | 
"+"  { return yytext[0];}  /* unsolved problem with concatenate string '+' */
"\"" {_state = YY_START; BEGIN DOUBLEQUOTES; str = yytext; column = yylloc->first_column; }
<DOUBLEQUOTES>\t|\\t { tab_count++; size_str += yyleng; }
<DOUBLEQUOTES>([\n !#-~]|\\\"|\r\n)* { size_str += yyleng; }
<DOUBLEQUOTES>\" { yylval->i = tab_count;
                   BEGIN _state;
                   yytext = str;
                   yyleng = size_str + 2;
                   yylloc->first_column = column;
                   return STRING;
                 }
<DOUBLEQUOTES>. |
<DOUBLEQUOTES><<EOF>> { return ERROR;}
"'"([\n\t -&\(-~]|\r\n)*"'" {return STRING;}
"0" {return ZERO;}
"-"[1-9][0-9]* {return INTEGER;}
[1-9][0-9]* {return NON_NEGATIVE_INTEGER;}
<PATH>"/" |
<PATH>"[" |
<PATH>"]" |
<PATH>"=" |
<PATH>"(" |
<PATH>")" |
<PATH>"+" {return yytext[0];}
<PATH>".." {return DOUBLEDOT;}
<PATH>\n  |
<PATH>\r\n { yylloc->last_column = 0; return EOL;}
<PATH>[ \t]+ { return WHITESPACE;}
<PATH>";" |
<PATH>"{" {BEGIN INITIAL; return yytext[0];}
<PATH>"\"" {_state = YY_START; BEGIN DOUBLEQUOTES; str = yytext; column = yylloc->first_column; }
<PATH>"'"([\n\t -&\(-~]|\r\n)*"'" {return STRING;}
<PATH>"//" {_state = YY_START; BEGIN COMMENT2;}
<PATH>"/*" {_state = YY_START; BEGIN COMMENT1;}
<PATH>[A-Za-z_][-A-Za-z0-9_\.]* {return IDENTIFIER;}
<PATH>[A-Za-z_][-A-Za-z0-9_\.]*:[A-Za-z_][-A-Za-z0-9_\.]*   {return IDENTIFIERPREFIX;}
[0-9]{4}[-][0-9]{2}[-][0-9]{2} {return REVISION_DATE;}
[A-Za-z_][-A-Za-z0-9_\.]* {return IDENTIFIER;}
[A-Za-z_][-A-Za-z0-9_\.]*:[A-Za-z_][-A-Za-z0-9_\.]*   {return IDENTIFIERPREFIX;}
([!#-&\(-:<-\[\]-z|~])+ {if (yytext[0]=='/') {
                           switch(yytext[1]) {
                             case '*': _state = YY_START; BEGIN COMMENT1; yyless(2); break;
                             case '/': yyless(2); _state = YY_START; BEGIN COMMENT2; break;
                             default:  return STRINGS;
                            }
                          } else {return STRINGS;} }
\n |
\r\n { yylloc->last_column = 0; return EOL; }
[ \t]+ { return WHITESPACE;}

. { return ERROR;}

%%