<?php

declare(strict_types=1);

namespace PhpMyAdmin\SqlParser\Components;

use PhpMyAdmin\SqlParser\Component;
use PhpMyAdmin\SqlParser\Context;
use PhpMyAdmin\SqlParser\Parser;
use PhpMyAdmin\SqlParser\TokensList;
use PhpMyAdmin\SqlParser\TokenType;

use function implode;
use function trim;

/**
 * Parses the definition of a key.
 *
 * Used for parsing `CREATE TABLE` statement.
 */
final class Key implements Component
{
    /**
     * All key options.
     */
    private const KEY_OPTIONS = [
        'KEY_BLOCK_SIZE' => [
            1,
            'var=',
        ],
        'USING' => [
            2,
            'var',
        ],
        'WITH PARSER' => [
            3,
            'var',
        ],
        'COMMENT' => [
            4,
            'var',
        ],
        // MariaDB options
        'CLUSTERING' => [
            4,
            'var=',
        ],
        'ENGINE_ATTRIBUTE' => [
            5,
            'var=',
        ],
        'SECONDARY_ENGINE_ATTRIBUTE' => [
            5,
            'var=',
        ],
        // MariaDB & MySQL options
        'VISIBLE' => 6,
        'INVISIBLE' => 6,
        // MariaDB options
        'IGNORED' => 10,
        'NOT IGNORED' => 10,
    ];

    /**
     * The name of this key.
     *
     * @var string
     */
    public $name;

    /**
     * The key columns
     *
     * @var array<int, array<string, int|string>>
     * @phpstan-var array{name?: string, length?: int, order?: string}[]
     */
    public $columns;

    /**
     * The type of this key.
     *
     * @var string
     */
    public $type;

    /**
     * The expression if the Key is not using column names
     *
     * @var string|null
     */
    public $expr = null;

    /**
     * The options of this key or null if none where found.
     *
     * @var OptionsArray|null
     */
    public $options;

    /**
     * @param string                                $name    the name of the key
     * @param array<int, array<string, int|string>> $columns the columns covered by this key
     * @param string                                $type    the type of this key
     * @param OptionsArray                          $options the options of this key
     * @phpstan-param array{name?: string, length?: int, order?: string}[] $columns
     */
    public function __construct(
        $name = null,
        array $columns = [],
        $type = null,
        $options = null
    ) {
        $this->name = $name;
        $this->columns = $columns;
        $this->type = $type;
        $this->options = $options;
    }

    /**
     * @param Parser               $parser  the parser that serves as context
     * @param TokensList           $list    the list of tokens that are being parsed
     * @param array<string, mixed> $options parameters for parsing
     */
    public static function parse(Parser $parser, TokensList $list, array $options = []): Key
    {
        $ret = new static();

        /**
         * Last parsed column.
         *
         * @var array<string,mixed>
         */
        $lastColumn = [];

        /**
         * The state of the parser.
         *
         * Below are the states of the parser.
         *
         *      0 ---------------------[ type ]---------------------------> 1
         *
         *      1 ---------------------[ name ]---------------------------> 1
         *      1 ---------------------[ columns ]------------------------> 2
         *      1 ---------------------[ expression ]---------------------> 5
         *
         *      2 ---------------------[ column length ]------------------> 3
         *      3 ---------------------[ column length ]------------------> 2
         *      2 ---------------------[ options ]------------------------> 4
         *      5 ---------------------[ expression ]---------------------> 4
         *
         * @var int
         */
        $state = 0;

        for (; $list->idx < $list->count; ++$list->idx) {
            /**
             * Token parsed at this moment.
             */
            $token = $list->tokens[$list->idx];

            // End of statement.
            if ($token->type === TokenType::Delimiter) {
                break;
            }

            // Skipping whitespaces and comments.
            if (($token->type === TokenType::Whitespace) || ($token->type === TokenType::Comment)) {
                continue;
            }

            if ($state === 0) {
                $ret->type = $token->value;
                $state = 1;
            } elseif ($state === 1) {
                if (($token->type === TokenType::Operator) && ($token->value === '(')) {
                    $positionBeforeSearch = $list->idx;
                    $list->idx++;// Ignore the current token "(" or the search condition will always be true
                    $nextToken = $list->getNext();
                    $list->idx = $positionBeforeSearch;// Restore the position

                    if ($nextToken !== null && $nextToken->value === '(') {
                        // Switch to expression mode
                        $state = 5;
                    } else {
                        $state = 2;
                    }
                } else {
                    $ret->name = $token->value;
                }
            } elseif ($state === 2) {
                if ($token->type === TokenType::Operator) {
                    if ($token->value === '(') {
                        $state = 3;
                    } elseif (($token->value === ',') || ($token->value === ')')) {
                        $state = $token->value === ',' ? 2 : 4;
                        if ($lastColumn !== []) {
                            $ret->columns[] = $lastColumn;
                            $lastColumn = [];
                        }
                    }
                } elseif (
                    (
                        $token->type === TokenType::Keyword
                    )
                    &&
                    (
                        ($token->keyword === 'ASC') || ($token->keyword === 'DESC')
                    )
                ) {
                    $lastColumn['order'] = $token->keyword;
                } else {
                    $lastColumn['name'] = $token->value;
                }
            } elseif ($state === 3) {
                if (($token->type === TokenType::Operator) && ($token->value === ')')) {
                    $state = 2;
                } else {
                    $lastColumn['length'] = $token->value;
                }
            } elseif ($state === 4) {
                $ret->options = OptionsArray::parse($parser, $list, self::KEY_OPTIONS);
                ++$list->idx;
                break;
            } elseif ($state === 5) {
                if ($token->type === TokenType::Operator) {
                    // This got back to here and we reached the end of the expression
                    if ($token->value === ')') {
                        $state = 4;// go back to state 4 to fetch options
                        continue;
                    }

                    // The expression is not finished, adding a separator for the next expression
                    if ($token->value === ',') {
                        $ret->expr .= ', ';
                        continue;
                    }

                    // Start of the expression
                    if ($token->value === '(') {
                        // This is the first expression, set to empty
                        if ($ret->expr === null) {
                            $ret->expr = '';
                        }

                        $ret->expr .= Expression::parse($parser, $list, ['parenthesesDelimited' => true]);
                        continue;
                    }
                    // Another unexpected operator was found
                }

                // Something else than an operator was found
                $parser->error('Unexpected token.', $token);
            }
        }

        --$list->idx;

        return $ret;
    }

    public function build(): string
    {
        $ret = $this->type . ' ';
        if (! empty($this->name)) {
            $ret .= Context::escape($this->name) . ' ';
        }

        if ($this->expr !== null) {
            return $ret . '(' . $this->expr . ') ' . $this->options;
        }

        $columns = [];
        foreach ($this->columns as $column) {
            $tmp = '';
            if (isset($column['name'])) {
                $tmp .= Context::escape($column['name']);
            }

            if (isset($column['length'])) {
                $tmp .= '(' . $column['length'] . ')';
            }

            if (isset($column['order'])) {
                $tmp .= ' ' . $column['order'];
            }

            $columns[] = $tmp;
        }

        $ret .= '(' . implode(',', $columns) . ') ' . $this->options;

        return trim($ret);
    }

    public function __toString(): string
    {
        return $this->build();
    }
}
