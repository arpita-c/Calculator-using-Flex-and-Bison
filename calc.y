
%{
    #include <stdio.h>
    #include<stdlib.h>
    #include <string.h>

    #define SYM_TAB_ELEMENTS 1000
%}

%locations

%token TOK_SEMICOLON TOK_SUB TOK_PRINT TOK_MUL TOK_LEFTFLOWERBRACE TOK_RIGHTFLOWERBRACE TOK_MAIN
%token TOK_LEFTROUNDBRACE TOK_RIGHTROUNDBRACE TOK_EQUALTO TOK_FLOAT TOK_FLOATNUM TOK_IDENTIFIER 

%union
{
    int line_no;
    float float_val;
    struct symbol_table id;
}

%type <float_val> TOK_FLOATNUM
%type <id> TOK_IDENTIFIER
%type <id> E

%left TOK_SUB
%left TOK_MUL

%code requires
{
    struct symbol_table
    {
        char variable_name[100];
        float variable_value;
        int is_initialized;
        int name_alt[100];
        int deletion_flag;
    };
}

%code 
{
    int j = 0;
    int deletion_flag_val=0;
    struct symbol_table tmp;
    struct symbol_table symbol_list[SYM_TAB_ELEMENTS];

    struct symbol_table* fetch_value(struct symbol_table id)
    {
        int k;

        for(k = 0; k <= j; k++)
        {
            if(!strcmp(id.variable_name,symbol_list[k].variable_name))
            {
                return &symbol_list[k];
            }
        }

        for(k = j; k >= 0; k--)
        {

            if((!strcmp(id.variable_name, symbol_list[k].name_alt)) && (symbol_list[k].deletion_flag < deletion_flag_val))
            {
                deletion_flag_val = symbol_list[k].deletion_flag;

                return &symbol_list[k];
            }            
        }    
        return NULL;
    }


    struct symbol_table* fetch_value_and_nullify(struct symbol_table id)
    {
        int k;

        for(k = j; k >= 0; k--)
        {
            if(!strcmp(id.variable_name, symbol_list[k].variable_name))
            {
                strcpy(tmp.variable_name, symbol_list[k].variable_name);
                strcpy(tmp.name_alt, symbol_list[k].name_alt);

                tmp.variable_value = symbol_list[k].variable_value;
                tmp.is_initialized = symbol_list[k].is_initialized;
                tmp.deletion_flag = symbol_list[k].deletion_flag;
                
                strcpy(symbol_list[k].name_alt, symbol_list[k].variable_name);
                strcpy(symbol_list[k].variable_name, "None");

                symbol_list[k].deletion_flag = deletion_flag_val+1;
                deletion_flag_val = deletion_flag_val+1;

                return &tmp;
            }
        }

        for(k = j; k >= 0; k--)
        {

            if((!strcmp(id.variable_name, symbol_list[k].name_alt)) && (symbol_list[k].deletion_flag < deletion_flag_val))
            {
                deletion_flag_val = symbol_list[k].deletion_flag;

                return &symbol_list[k];
            }            
        }    
        return NULL;
    }

}

%%

Prog : TOK_MAIN TOK_LEFTROUNDBRACE TOK_RIGHTROUNDBRACE  TOK_LEFTFLOWERBRACE  Stmts TOK_RIGHTFLOWERBRACE
;

Stmts:    /*This is epsilon - null token */
        | Stmt TOK_SEMICOLON Stmts
        ;

Stmt :
        | TOK_FLOAT TOK_IDENTIFIER

        {
            struct symbol_table destid;
            j++;
            strcpy(symbol_list[j].variable_name, $2.variable_name);
        }

        | TOK_IDENTIFIER TOK_EQUALTO E

        {
            struct symbol_table *id = fetch_value($1);
            if(!id)
            {
                fprintf(stderr,"%s parsing error.\n",$1.variable_name);
                return -1;
            }
            else
            {
                id->variable_value=$3.variable_value;
            }
                
        }

        | TOK_PRINT TOK_IDENTIFIER

        {
            struct symbol_table *id = fetch_value_and_nullify($2);
            if(id)
            {
                    fprintf(stdout,"%.1f\n",id->variable_value);   
                                
            }
            else
            {
                fprintf(stderr,"parsing error");
                return -1;
            }
        }

        | TOK_LEFTFLOWERBRACE Stmts TOK_RIGHTFLOWERBRACE
        
        ;

E : TOK_IDENTIFIER
        {
            struct symbol_table *id = fetch_value($1);
            if(!id)
            {
                fprintf(stderr,"%s not defined.\n",$1.variable_name);
                return -1;
            }
            $$ = *id;
        }

        | TOK_FLOATNUM
        {
            $$.variable_value = $1;
        }

        | E TOK_SUB E
        {
            $$.variable_value = $1.variable_value - $3.variable_value;
        }

        | E TOK_MUL E

        {
            $$.variable_value = $1.variable_value * $3.variable_value;
        }

        | TOK_LEFTROUNDBRACE TOK_SUB TOK_FLOATNUM TOK_RIGHTROUNDBRACE
        {
            $$.variable_value = -$3;
        }

        ;

%%

int main()
{
    yyparse();
    return 0;
}


