<?php

declare(strict_types=1);

namespace PhpMyAdmin\SqlParser\Components;

use PhpMyAdmin\SqlParser\Component;
use PhpMyAdmin\SqlParser\Parser;
use PhpMyAdmin\SqlParser\TokensList;
use PhpMyAdmin\SqlParser\TokenType;

use function implode;

/**
 * `RENAME TABLE` keyword parser.
 */
final class RenameOperation implements Component
{
    /**
     * The old table name.
     *
     * @var Expression
     */
    public $old;

    /**
     * The new table name.
     *
     * @var Expression
     */
    public $new;

    /**
     * @param Expression $old old expression
     * @param Expression $new new expression containing new name
     */
    public function __construct($old = null, $new = null)
    {
        $this->old = $old;
        $this->new = $new;
    }

    /**
     * @param Parser               $parser  the parser that serves as context
     * @param TokensList           $list    the list of tokens that are being parsed
     * @param array<string, mixed> $options parameters for parsing
     *
     * @return RenameOperation[]
     */
    public static function parse(Parser $parser, TokensList $list, array $options = []): array
    {
        $ret = [];

        $expr = new static();

        /**
         * The state of the parser.
         *
         * Below are the states of the parser.
         *
         *      0 ---------------------[ old name ]--------------------> 1
         *
         *      1 ------------------------[ TO ]-----------------------> 2
         *
         *      2 ---------------------[ new name ]--------------------> 3
         *
         *      3 ------------------------[ , ]------------------------> 0
         *      3 -----------------------[ else ]----------------------> (END)
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
                $expr->old = Expression::parse(
                    $parser,
                    $list,
                    [
                        'breakOnAlias' => true,
                        'parseField' => 'table',
                    ]
                );
                if (empty($expr->old)) {
                    $parser->error('The old name of the table was expected.', $token);
                }

                $state = 1;
            } elseif ($state === 1) {
                if ($token->type !== TokenType::Keyword || $token->keyword !== 'TO') {
                    $parser->error('Keyword "TO" was expected.', $token);
                    break;
                }

                $state = 2;
            } elseif ($state === 2) {
                $expr->new = Expression::parse(
                    $parser,
                    $list,
                    [
                        'breakOnAlias' => true,
                        'parseField' => 'table',
                    ]
                );
                if (empty($expr->new)) {
                    $parser->error('The new name of the table was expected.', $token);
                }

                $state = 3;
            } elseif ($state === 3) {
                if (($token->type !== TokenType::Operator) || ($token->value !== ',')) {
                    break;
                }

                $ret[] = $expr;
                $expr = new static();
                $state = 0;
            }
        }

        if ($state !== 3) {
            $parser->error('A rename operation was expected.', $list->tokens[$list->idx - 1]);
        }

        // Last iteration was not saved.
        if (! empty($expr->old)) {
            $ret[] = $expr;
        }

        --$list->idx;

        return $ret;
    }

    public function build(): string
    {
        return $this->old . ' TO ' . $this->new;
    }

    /**
     * @param RenameOperation[] $component the component to be built
     */
    public static function buildAll(array $component): string
    {
        return implode(', ', $component);
    }

    public function __toString(): string
    {
        return $this->build();
    }
}
