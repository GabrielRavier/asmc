/****************************************************************************
*
*  This code is Public Domain.
*
*  ========================================================================
*
* Description:	directives END, .STARTUP and .EXIT
*
****************************************************************************/

#include <globals.h>
#include <memalloc.h>
#include <parser.h>
#include <segment.h>
#include <extern.h>
#include <fixup.h>
#include <lqueue.h>
#include <tokenize.h>
#include <expreval.h>
#include <types.h>
#include <listing.h>
#include <proc.h>
#include <omf.h>
#include <mangle.h>
#include <bin.h>

/* prototypes */
extern ret_code idata_fixup( struct code_info *, unsigned, struct expr * );

struct code_line {
    const char *src;
    const short r1;
    const short r2;
};

/* startup code for 8086 */

#ifndef __ASMC64__
static const struct code_line StartupDosNear0[] = {
    { "mov %r,DGROUP", T_DX, T_NULL },
    { "mov %r,%r", T_DS, T_DX	    },
    { "mov %r,%r", T_BX, T_SS	    },
    { "sub %r,%r", T_BX, T_DX	    },
    { "shl %r,1",  T_BX, T_NULL	    },
    { "shl %r,1",  T_BX, T_NULL	    },
    { "shl %r,1",  T_BX, T_NULL	    },
    { "shl %r,1",  T_BX, T_NULL	    },
    { "cli",	   T_NULL, T_NULL   },
    { "mov %r,%r", T_SS, T_DX	    },
    { "add %r,%r", T_SP, T_BX	    },
    { "sti",	   T_NULL, T_NULL   },
};

/* startup code for 80186+ */

static const struct code_line StartupDosNear1[] = {
    { "mov %r,DGROUP", T_AX, T_NULL },
    { "mov %r,%r",     T_DS, T_AX   },
    { "mov %r,%r",     T_BX, T_SS   },
    { "sub %r,%r",     T_BX, T_AX   },
    { "shl %r,4",      T_BX, T_NULL },
    { "mov %r,%r",     T_SS, T_AX   },
    { "add %r,%r",     T_SP, T_BX   },
};

static const struct code_line StartupDosFar[] = {
    { "mov %r,DGROUP", T_DX, T_NULL },
    { "mov %r,%r"    , T_DS, T_DX   },
};

static const struct code_line ExitOS2[] = { /* mov al, retval  followed by: */
    { "mov %r,0",     T_AH,  T_NULL  },
    { "push 1",	      T_NULL,T_NULL  },
    { "push %r",      T_AX,  T_NULL  },
    { "call DOSEXIT", T_NULL,T_NULL  },
};

static const struct code_line ExitDos[] = {
    { "mov %r,4ch",  T_AH,  T_NULL  },
    { "int 21h",     T_NULL,T_NULL  },
};

static const char szStartAddr[] = {"@Startup"};

/* .STARTUP and .EXIT directives */

int StartupExitDirective( int i, struct asm_tok tokenarray[] )
/*****************************************************************/
{
    int		count;
    ret_code	rc = NOT_ERROR;
    int		j;
    const struct code_line *p;
    struct expr opndx;

    LstWriteSrcLine();

    if( ModuleInfo.model == MODEL_NONE ) {
	return( asmerr( 2013 ) );
    }
    if ( ModuleInfo.Ofssize > USE16 ) {
	return( asmerr( 2199 ) ); //, tokenarray[i].string_ptr ) );
    }

    switch( tokenarray[i].tokval ) {
    case T_DOT_STARTUP:
	count = 0;
	/* for tiny model, set current PC to 100h. */
	if ( ModuleInfo.model == MODEL_TINY )
	    AddLineQueue( "org 100h" );
	AddLineQueueX( "%s::", szStartAddr );
	if( ModuleInfo.ostype == OPSYS_DOS ) {
	    if ( ModuleInfo.model == MODEL_TINY )
		;
	    else {
		if( ModuleInfo.distance == STACK_NEAR ) {
		    if ( ( ModuleInfo.cpu & M_CPUMSK ) <= M_8086 ) {
			p = StartupDosNear0;
			count = sizeof( StartupDosNear0 ) / sizeof( StartupDosNear0[0] );
		    } else {
			p = StartupDosNear1;
			count = sizeof( StartupDosNear1 ) / sizeof( StartupDosNear1[0] );
		    }
		} else {
		    p = StartupDosFar;
		    count = sizeof( StartupDosFar ) / sizeof( StartupDosFar[0] );
		}
		for ( ; count ; count--, p++ )
		    AddLineQueueX( (char *)p->src, p->r1, p->r2 );
	    }
	}
	ModuleInfo.StartupDirectiveFound = TRUE;
	i++; /* skip directive token */
	break;
    case T_DOT_EXIT:
	if( ModuleInfo.ostype == OPSYS_DOS ) {
	    p = ExitDos;
	    count = sizeof( ExitDos ) / sizeof( ExitDos[0] );
	} else {
	    p = ExitOS2;
	    count = sizeof( ExitOS2 ) / sizeof( ExitOS2[0] );
	}
	i++; /* skip directive token */
	if ( tokenarray[i].token != T_FINAL ) {
	    if( ModuleInfo.ostype == OPSYS_OS2 ) {
		AddLineQueueX( "mov %r,%s", T_AX, tokenarray[i].tokpos );
		i = Token_Count;
	    } else {
		j = i;
		if ( EvalOperand( &i, tokenarray, Token_Count, &opndx, 0 ) == ERROR )
		    return( ERROR );
		if ( opndx.kind == EXPR_CONST && opndx.value < 0x100 ) {
		    AddLineQueueX( "mov %r,4C00h + %u", T_AX, opndx.value );
		} else {
		    AddLineQueueX( "mov %r,%s", T_AL, tokenarray[j].tokpos );
		    AddLineQueueX( "mov %r,4Ch", T_AH );
		}
	    }
	    p++;
	    count--;
	}

	for( ; count ; count--, p++ ) {
	    AddLineQueueX( (char *)p->src, p->r1, p->r2 );
	}
	break;
    }
    if ( tokenarray[i].token != T_FINAL ) {
	asmerr(2008, tokenarray[i].tokpos );
	rc = ERROR;
    }

    RunLineQueue();

    return( rc );
}

#endif

/* END directive */

ret_code EndDirective( int i, struct asm_tok tokenarray[] )
/*********************************************************/
{
    struct expr		opndx;

    i++; /* skip directive */

    /* v2.08: END may generate code, so write listing first */
    LstWriteSrcLine();

    /* v2.05: first parse the arguments. this allows
     * SegmentModuleExit() later to run generated code.
     */
#ifndef __ASMC64__
    if( ModuleInfo.StartupDirectiveFound ) {
	/* start label behind END ignored if .STARTUP has been found */
	if( i < Token_Count && Parse_Pass == PASS_1 ) {
	    asmerr( 4003 );
	}
	i = Token_Count + 1;
	tokenarray[i].token = T_ID;
	tokenarray[i].string_ptr = (char *)szStartAddr;
	tokenarray[i+1].token = T_FINAL;
	tokenarray[i+1].string_ptr = "";
	Token_Count = i+1;
    }
#endif
    /* v2.11: flag EXPF_NOUNDEF added - will return ERROR if start label isn't defined */
    if( EvalOperand( &i, tokenarray, Token_Count, &opndx, EXPF_NOUNDEF ) == ERROR ) {
	return( ERROR );
    }
    if( tokenarray[i].token != T_FINAL ) {
	return( asmerr(2008, tokenarray[i].tokpos ) );
    }

    if ( CurrStruct ) {
	while ( CurrStruct->next )
	    CurrStruct = CurrStruct->next;
	asmerr( 1010, CurrStruct->sym.name );
    }
    /* v2.10: check for open PROCedures */
    ProcCheckOpen();

    /* check type of start label. Must be a symbolic code label, internal or external */
    if ( opndx.kind == EXPR_ADDR && opndx.indirect == FALSE &&
	( opndx.mem_type == MT_NEAR || opndx.mem_type == MT_FAR || ( opndx.mem_type == MT_EMPTY && opndx.instr == T_OFFSET ) ) &&
	opndx.sym && (	opndx.sym->state == SYM_INTERNAL || opndx.sym->state == SYM_EXTERNAL ) ) {

	if ( Options.output_format == OFORMAT_OMF ) {
	    struct code_info	CodeInfo;
	    CodeInfo.opnd[0].InsFixup = NULL;
	    CodeInfo.token = T_NOP;
	    CodeInfo.pinstr = &InstrTable[IndexFromToken( T_NOP )];
	    CodeInfo.flags = 0;
	    CodeInfo.mem_type = MT_EMPTY;
	    idata_fixup( &CodeInfo, 0, &opndx );
	    ModuleInfo.g.start_fixup = CodeInfo.opnd[0].InsFixup;
	    ModuleInfo.g.start_displ = opndx.value;
	} else {
	    if ( opndx.sym->state != SYM_EXTERNAL && opndx.sym->ispublic == FALSE ) {
		opndx.sym->ispublic = TRUE;
		AddPublicData( opndx.sym );
	    }
	    ModuleInfo.g.start_label = opndx.sym;
	}
    } else if ( opndx.kind != EXPR_EMPTY ) {
	return( asmerr( 2094 ) );
    }

    /* close open segments */
    SegmentModuleExit();

    if ( ModuleInfo.g.EndDirHook )
	ModuleInfo.g.EndDirHook( &ModuleInfo );

    ModuleInfo.EndDirFound = TRUE;

    return( NOT_ERROR );
}

