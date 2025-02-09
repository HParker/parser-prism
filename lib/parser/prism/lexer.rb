# frozen_string_literal: true

module Parser
  class Prism
    # Accepts a list of prism tokens and converts them into the expected format
    # for the parser gem.
    class Lexer
      TYPES = {
        # These tokens should never appear in the output of the lexer.
        EOF: nil,
        MISSING: nil,
        NOT_PROVIDED: nil,
        IGNORED_NEWLINE: nil,
        EMBDOC_END: nil,
        EMBDOC_LINE: nil,
        __END__: nil,

        # These tokens have more or less direct mappings.
        AMPERSAND: :tAMPER2,
        AMPERSAND_AMPERSAND: :tANDOP,
        AMPERSAND_AMPERSAND_EQUAL: :tOP_ASGN,
        AMPERSAND_DOT: :tANDDOT,
        AMPERSAND_EQUAL: :tOP_ASGN,
        BACK_REFERENCE: :tBACK_REF,
        BACKTICK: :tXSTRING_BEG,
        BANG: :tBANG,
        BANG_EQUAL: :tNEQ,
        BANG_TILDE: :tNMATCH,
        BRACE_LEFT: :tLCURLY,
        BRACE_RIGHT: :tRCURLY,
        BRACKET_LEFT: :tLBRACK2,
        BRACKET_LEFT_ARRAY: :tLBRACK,
        BRACKET_LEFT_RIGHT: :tAREF,
        BRACKET_LEFT_RIGHT_EQUAL: :tASET,
        BRACKET_RIGHT: :tRBRACK,
        CARET: :tCARET,
        CARET_EQUAL: :tOP_ASGN,
        CHARACTER_LITERAL: :tCHARACTER,
        CLASS_VARIABLE: :tCVAR,
        COLON: :tCOLON,
        COLON_COLON: :tCOLON2,
        COMMA: :tCOMMA,
        COMMENT: :tCOMMENT,
        CONSTANT: :tCONSTANT,
        DOT: :tDOT,
        DOT_DOT: :tDOT2,
        DOT_DOT_DOT: :tDOT3,
        EMBDOC_BEGIN: :tCOMMENT,
        EMBEXPR_BEGIN: :tSTRING_DBEG,
        EMBEXPR_END: :tSTRING_DEND,
        EMBVAR: :tSTRING_DVAR,
        EQUAL: :tEQL,
        EQUAL_EQUAL: :tEQ,
        EQUAL_EQUAL_EQUAL: :tEQQ,
        EQUAL_GREATER: :tASSOC,
        EQUAL_TILDE: :tMATCH,
        FLOAT: :tFLOAT,
        FLOAT_IMAGINARY: :tIMAGINARY,
        FLOAT_RATIONAL: :tRATIONAL,
        FLOAT_RATIONAL_IMAGINARY: :tIMAGINARY,
        GLOBAL_VARIABLE: :tGVAR,
        GREATER: :tGT,
        GREATER_EQUAL: :tGEQ,
        GREATER_GREATER: :tRSHFT,
        GREATER_GREATER_EQUAL: :tOP_ASGN,
        HEREDOC_START: :tSTRING_BEG,
        HEREDOC_END: :tSTRING_END,
        IDENTIFIER: :tIDENTIFIER,
        INSTANCE_VARIABLE: :tIVAR,
        INTEGER: :tINTEGER,
        INTEGER_IMAGINARY: :tIMAGINARY,
        INTEGER_RATIONAL: :tRATIONAL,
        INTEGER_RATIONAL_IMAGINARY: :tIMAGINARY,
        KEYWORD_ALIAS: :kALIAS,
        KEYWORD_AND: :kAND,
        KEYWORD_BEGIN: :kBEGIN,
        KEYWORD_BEGIN_UPCASE: :klBEGIN,
        KEYWORD_BREAK: :kBREAK,
        KEYWORD_CASE: :kCASE,
        KEYWORD_CLASS: :kCLASS,
        KEYWORD_DEF: :kDEF,
        KEYWORD_DEFINED: :kDEFINED,
        KEYWORD_DO: :kDO,
        KEYWORD_DO_LOOP: :kDO_COND,
        KEYWORD_END: :kEND,
        KEYWORD_END_UPCASE: :klEND,
        KEYWORD_ENSURE: :kENSURE,
        KEYWORD_ELSE: :kELSE,
        KEYWORD_ELSIF: :kELSIF,
        KEYWORD_FALSE: :kFALSE,
        KEYWORD_FOR: :kFOR,
        KEYWORD_IF: :kIF,
        KEYWORD_IF_MODIFIER: :kIF_MOD,
        KEYWORD_IN: :kIN,
        KEYWORD_MODULE: :kMODULE,
        KEYWORD_NEXT: :kNEXT,
        KEYWORD_NIL: :kNIL,
        KEYWORD_NOT: :kNOT,
        KEYWORD_OR: :kOR,
        KEYWORD_REDO: :kREDO,
        KEYWORD_RESCUE: :kRESCUE,
        KEYWORD_RESCUE_MODIFIER: :kRESCUE_MOD,
        KEYWORD_RETRY: :kRETRY,
        KEYWORD_RETURN: :kRETURN,
        KEYWORD_SELF: :kSELF,
        KEYWORD_SUPER: :kSUPER,
        KEYWORD_THEN: :kTHEN,
        KEYWORD_TRUE: :kTRUE,
        KEYWORD_UNDEF: :kUNDEF,
        KEYWORD_UNLESS: :kUNLESS,
        KEYWORD_UNLESS_MODIFIER: :kUNLESS_MOD,
        KEYWORD_UNTIL: :kUNTIL,
        KEYWORD_UNTIL_MODIFIER: :kUNTIL_MOD,
        KEYWORD_WHEN: :kWHEN,
        KEYWORD_WHILE: :kWHILE,
        KEYWORD_WHILE_MODIFIER: :kWHILE_MOD,
        KEYWORD_YIELD: :kYIELD,
        KEYWORD___ENCODING__: :k__ENCODING__,
        KEYWORD___FILE__: :k__FILE__,
        KEYWORD___LINE__: :k__LINE__,
        LABEL: :tLABEL,
        LABEL_END: :tLABEL_END,
        LAMBDA_BEGIN: :tLAMBEG,
        LESS: :tLT,
        LESS_EQUAL: :tLEQ,
        LESS_EQUAL_GREATER: :tCMP,
        LESS_LESS: :tLSHFT,
        LESS_LESS_EQUAL: :tOP_ASGN,
        METHOD_NAME: :tFID,
        MINUS: :tMINUS,
        MINUS_EQUAL: :tOP_ASGN,
        MINUS_GREATER: :tLAMBDA,
        NEWLINE: :tNL,
        NUMBERED_REFERENCE: :tNTH_REF,
        PARENTHESIS_LEFT: :tLPAREN,
        PARENTHESIS_LEFT_PARENTHESES: :tLPAREN_ARG,
        PARENTHESIS_RIGHT: :tRPAREN,
        PERCENT: :tPERCENT,
        PERCENT_EQUAL: :tOP_ASGN,
        PERCENT_LOWER_I: :tQSYMBOLS_BEG,
        PERCENT_LOWER_W: :tQWORDS_BEG,
        PERCENT_UPPER_I: :tSYMBOLS_BEG,
        PERCENT_UPPER_W: :tWORDS_BEG,
        PERCENT_LOWER_X: :tXSTRING_BEG,
        PLUS: :tPLUS,
        PLUS_EQUAL: :tOP_ASGN,
        PIPE_EQUAL: :tOP_ASGN,
        PIPE: :tPIPE,
        PIPE_PIPE: :tOROP,
        PIPE_PIPE_EQUAL: :tOP_ASGN,
        QUESTION_MARK: :tEH,
        REGEXP_BEGIN: :tREGEXP_BEG,
        REGEXP_END: :tSTRING_END,
        SEMICOLON: :tSEMI,
        SLASH: :tDIVIDE,
        SLASH_EQUAL: :tOP_ASGN,
        STAR: :tSTAR2,
        STAR_EQUAL: :tOP_ASGN,
        STAR_STAR: :tPOW,
        STAR_STAR_EQUAL: :tOP_ASGN,
        STRING_BEGIN: :tSTRING_BEG,
        STRING_CONTENT: :tSTRING_CONTENT,
        STRING_END: :tSTRING_END,
        SYMBOL_BEGIN: :tSYMBEG,
        TILDE: :tTILDE,
        UAMPERSAND: :tAMPER,
        UCOLON_COLON: :tCOLON3,
        UDOT_DOT: :tDOT2,
        UDOT_DOT_DOT: :tBDOT3,
        UMINUS: :tUMINUS,
        UMINUS_NUM: :tUNARY_NUM,
        UPLUS: :tUPLUS,
        USTAR: :tSTAR,
        USTAR_STAR: :tPOW,
        WORDS_SEP: :tSPACE
      }
  
      private_constant :TYPES

      attr_reader :buffer, :lexed

      def initialize(buffer, lexed)
        @buffer = buffer
        @lexed = lexed
      end

      def to_a
        tokens = []
        index = 0
  
        while index < lexed.length
          token, = lexed[index]
          index += 1
          next if token.type == :IGNORED_NEWLINE || token.type == :EOF
  
          type = TYPES.fetch(token.type)
          value = token.value
          location = Source::Range.new(buffer, token.location.start_offset, token.location.end_offset)
  
          case type
          when :tCHARACTER
            value.delete_prefix!("?")
          when :tCOMMENT
            if token.type == :EMBDOC_BEGIN
              until (next_token = lexed[index]) && next_token.type == :EMBDOC_END
                value += next_token.location.slice
                index += 1
              end
  
              value += lexed[index].location.slice
              location = Source::Range.new(buffer, token.location.start_offset, lexed[index].location.end_offset)
              index += 1
            else
              value.chomp!
              location = Source::Range.new(buffer, token.location.start_offset, token.location.end_offset - 1)
            end
          when :tNL
            value = nil
          when :tFLOAT
            value = Float(value)
          when :tIMAGINARY
            value.chomp!("i")
            value = Complex(0, value.end_with?("r") ? Rational(value.chomp("r")) : value)
          when :tINTEGER
            if value.start_with?("+")
              tokens << [:tUNARY_NUM, ["+", Source::Range.new(buffer, token.location.start_offset, token.location.start_offset + 1)]]
              location = Source::Range.new(buffer, token.location.start_offset + 1, token.location.end_offset)
            end
  
            value = Integer(value)
          when :tLABEL
            value.chomp!(":")
          when :tLABEL_END
            value.chomp!(":")
          when :tNTH_REF
            value = Integer(value.delete_prefix("$"))
          when :tOP_ASGN
            value.chomp!("=")
          when :tRATIONAL
            value = Rational(value.chomp("r"))
          when :tSPACE
            value = nil
          when :tSTRING_BEG
            if ["\"", "'"].include?(value) && (next_token = lexed[index]) && next_token.type == :STRING_END
              next_location = token.location.join(next_token.location)
              type = :tSTRING
              value = ""
              location = Source::Range.new(buffer, next_location.start_offset, next_location.end_offset)
              index += 1
            elsif ["\"", "'"].include?(value) && (next_token = lexed[index]) && next_token.type == :STRING_CONTENT && (next_next_token = lexed[index + 1]) && next_next_token.type == :STRING_END
              next_location = token.location.join(next_next_token.location)
              type = :tSTRING
              value = next_token.location.slice
              location = Source::Range.new(buffer, next_location.start_offset, next_location.end_offset)
              index += 2
            end
          when :tSTRING_DVAR
            value = nil
          when :tSTRING_END
            if token.type == :REGEXP_END
              value = value[0]
              location = Source::Range.new(buffer, token.location.start_offset, token.location.start_offset + 1)
            end
          when :tSYMBEG
            if (next_token = lexed[index]) && next_token.type == :IDENTIFIER
              next_location = token.location.join(next_token.location)
              type = :tSYMBOL
              value = next_token.location.slice
              location = Source::Range.new(buffer, next_location.start_offset, next_location.end_offset)
              index += 1
            end
          end
  
          tokens << [type, [value, location]]
  
          if token.type == :REGEXP_END
            tokens << [:tREGEXP_OPT, [token.location.slice[1..], Source::Range.new(buffer, token.location.start_offset + 1, token.location.end_offset)]]
          end
        end

        tokens
      end
    end
  end
end
