<?php

use PhpCsFixer\Config;
use PhpCsFixer\Finder;

ini_set('memory_limit', '256M');

$rules = [
    '@PSR2' => true,
    '@Symfony' => true,
    '@PhpCsFixer' => true,
    '@PHP8x5Migration' => true,
    'heredoc_indentation' => false,
    'array_indentation' => true,
    'array_syntax' => ['syntax' => 'short'],
    'combine_consecutive_unsets' => true,
    'class_attributes_separation' => true,
    'multiline_whitespace_before_semicolons' => true,
    'single_quote' => true,
    'binary_operator_spaces' => [
        'default' => 'single_space',
        'operators' => [],
    ],
    'blank_line_after_opening_tag' => true,
    'blank_line_before_statement' => true,
    'single_space_around_construct' => true,
    'cast_spaces' => true,
    'class_definition' => [
        'single_line' => false,
        'space_before_parenthesis' => true,
    ],
    'concat_space' => ['spacing' => 'one'],
    'declare_equal_normalize' => true,
    'type_declaration_spaces' => true,
    'single_line_comment_style' => false,
    'include' => true,
    'lowercase_cast' => true,
    'native_function_casing' => true,
    'new_with_parentheses' => true,
    'no_blank_lines_after_class_opening' => true,
    'no_blank_lines_after_phpdoc' => true,
    'no_empty_comment' => true,
    'no_empty_phpdoc' => true,
    'no_empty_statement' => true,
    'no_extra_blank_lines' => [
        'tokens' => [
            'curly_brace_block',
            'extra',
            'parenthesis_brace_block',
            'square_brace_block',
            'throw',
            'use',
        ],
    ],
    'no_leading_import_slash' => true,
    'no_leading_namespace_whitespace' => true,
    'no_mixed_echo_print' => ['use' => 'echo'],
    'no_multiline_whitespace_around_double_arrow' => true,
    // 'no_short_bool_cast' => true,
    'no_singleline_whitespace_before_semicolons' => true,
    'no_spaces_around_offset' => true,
    'no_trailing_comma_in_singleline' => true,
    'no_unneeded_control_parentheses' => true,
    'no_unused_imports' => true,
    'ordered_imports' => true,
    'no_whitespace_before_comma_in_array' => true,
    'no_whitespace_in_blank_line' => true,
    'normalize_index_brace' => true,
    'object_operator_without_whitespace' => true,
    'php_unit_fqcn_annotation' => true,
    'phpdoc_align' => true,
    'phpdoc_annotation_without_dot' => true,
    'phpdoc_indent' => true,
    'phpdoc_line_span' => true,
    'phpdoc_no_access' => true,
    'phpdoc_no_alias_tag' => true,
    'phpdoc_no_empty_return' => true,
    'phpdoc_no_package' => true,
    'phpdoc_no_useless_inheritdoc' => true,
    'phpdoc_return_self_reference' => true,
    'phpdoc_scalar' => true,
    'phpdoc_separation' => true,
    'phpdoc_single_line_var_spacing' => true,
    'phpdoc_summary' => true,
    'phpdoc_to_comment' => false,
    'phpdoc_trim' => true,
    'phpdoc_types' => true,
    'phpdoc_var_without_name' => true,
    'increment_style' => true,
    'return_type_declaration' => true,
    // 'self_accessor' => true,
    'short_scalar_cast' => true,
    'blank_lines_before_namespace' => true,
    'single_class_element_per_statement' => true,
    'space_after_semicolon' => true,
    'standardize_not_equals' => true,
    'ternary_operator_spaces' => true,
    'trailing_comma_in_multiline' => true,
    'trim_array_spaces' => true,
    'unary_operator_spaces' => true,
    'whitespace_after_comma_in_array' => true,
    'method_argument_space' => [
        'on_multiline' => 'ensure_fully_multiline',
        'keep_multiple_spaces_after_comma' => false,
    ],
    'single_line_throw' => false,
];

$project_path = __DIR__;

$finder = Finder::create()
    ->in([
        $project_path . '/app',
        $project_path . '/config',
        $project_path . '/database',
        $project_path . '/resources',
        $project_path . '/routes',
        $project_path . '/tests',
    ])
    ->name('*.php')
    ->notName('*.blade.php')
    ->notName('*.stub')
    ->notName('_ide_helper*.php')
    ->notName('.phpstorm.meta.php')
    ->ignoreDotFiles(true)
    ->ignoreVCS(true);

$config = new Config();

return $config
    ->setRules($rules)
    ->setFinder($finder)
    ->setLineEnding("\n")
    ->setCacheFile($project_path . '/.php-cs-fixer.cache');
