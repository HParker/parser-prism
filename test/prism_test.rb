# frozen_string_literal: true

require "bundler/setup"
$:.unshift(File.expand_path("../lib", __dir__))

require "test/unit"
require "parser/prism"
require "parser/prism/compare"

class PrismTest < Test::Unit::TestCase
  skip = [
    # These files contain invalid syntax. We should never try to parse them.
    "control_meta_escape_chars_in_regexp__since_31.rb",
    "newline_in_hash_argument.rb",
    "pattern_match.rb",
    "range_endless.rb",
    "unary_num_pow_precedence.rb",

    # This is some kind of difference between when we combine dstr into str
    # sexps on escaped newlines.
    "parser_slash_slash_n_escaping_in_literals.rb",
    "ruby_bug_11989.rb",

    # We don't yet support numbered parameters. This is a bug in prism.
    "numbered_args_after_27.rb",
    "ruby_bug_15789.rb",

    # We have an issue here with rescue modifier precedence. This is a bug in
    # prism.
    "endless_method_command_syntax.rb",
    "ruby_bug_12402.rb",

    # These are location bounds issues. They are bugs in translation, but not
    # bugs in prism.
    "bug_rescue_empty_else.rb",
    "ensure_empty.rb",
    "rescue_else.rb",
    "rescue_else_ensure.rb",
    "rescue_in_lambda_block.rb",

    # Some kind of issue with the end location of heredocs including newlines.
    "dedenting_heredoc.rb",
    "parser_drops_truncated_parts_of_squiggly_heredoc.rb"
  ]

  # We haven't fully implemented tokenization properly yet. Most of these are
  # heredocs, and a couple are just random bugs.
  skip_tokens = [
    "args.rb",
    "beginless_erange_after_newline.rb",
    "beginless_irange_after_newline.rb",
    "beginless_range.rb",
    "bug_ascii_8bit_in_literal.rb",
    "bug_heredoc_do.rb",
    "dedenting_interpolating_heredoc_fake_line_continuation.rb",
    "dedenting_non_interpolating_heredoc_line_continuation.rb",
    "forward_arg_with_open_args.rb",
    "heredoc.rb",
    "interp_digit_var.rb",
    "multiple_pattern_matches.rb",
    "newline_in_hash_argument.rb",
    "parser_bug_640.rb",
    "parser_drops_truncated_parts_of_squiggly_heredoc.rb",
    "ruby_bug_11990.rb",
    "ruby_bug_9669.rb",
    "slash_newline_in_heredocs.rb"
  ]

  base = File.expand_path("fixtures", __dir__)
  Dir["*.rb", base: base].each do |filename|
    next if skip.include?(filename)

    filepath = File.join(base, filename)
    compare_tokens = !skip_tokens.include?(filename)

    define_method("test_#{filepath}") do
      assert(Parser::Prism.compare(filepath, compare_tokens: compare_tokens))
    end
  end
end
