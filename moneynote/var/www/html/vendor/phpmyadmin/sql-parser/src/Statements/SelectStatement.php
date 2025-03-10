<?php

declare(strict_types=1);

namespace PhpMyAdmin\SqlParser\Statements;

use PhpMyAdmin\SqlParser\Components\ArrayObj;
use PhpMyAdmin\SqlParser\Components\Condition;
use PhpMyAdmin\SqlParser\Components\Expression;
use PhpMyAdmin\SqlParser\Components\FunctionCall;
use PhpMyAdmin\SqlParser\Components\GroupKeyword;
use PhpMyAdmin\SqlParser\Components\IndexHint;
use PhpMyAdmin\SqlParser\Components\IntoKeyword;
use PhpMyAdmin\SqlParser\Components\JoinKeyword;
use PhpMyAdmin\SqlParser\Components\Limit;
use PhpMyAdmin\SqlParser\Components\OptionsArray;
use PhpMyAdmin\SqlParser\Components\OrderKeyword;
use PhpMyAdmin\SqlParser\Statement;

/**
 * `SELECT` statement.
 *
 * SELECT
 *     [ALL | DISTINCT | DISTINCTROW ]
 *       [HIGH_PRIORITY]
 *       [MAX_STATEMENT_TIME = N]
 *       [STRAIGHT_JOIN]
 *       [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
 *       [SQL_CACHE | SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
 *     select_expr [, select_expr ...]
 *     [FROM table_references
 *       [PARTITION partition_list]
 *     [WHERE where_condition]
 *     [GROUP BY {col_name | expr | position}
 *       [ASC | DESC], ... [WITH ROLLUP]]
 *     [HAVING where_condition]
 *     [ORDER BY {col_name | expr | position}
 *       [ASC | DESC], ...]
 *     [LIMIT {[offset,] row_count | row_count OFFSET offset}]
 *     [PROCEDURE procedure_name(argument_list)]
 *     [INTO OUTFILE 'file_name'
 *         [CHARACTER SET charset_name]
 *         export_options
 *       | INTO DUMPFILE 'file_name'
 *       | INTO var_name [, var_name]]
 *     [FOR UPDATE | LOCK IN SHARE MODE]]
 */
class SelectStatement extends Statement
{
    /**
     * Options for `SELECT` statements and their slot ID.
     *
     * @var array<string, int|array<int, int|string>>
     * @psalm-var array<string, (positive-int|array{positive-int, ('var'|'var='|'expr'|'expr=')})>
     */
    public static $statementOptions = [
        'ALL' => 1,
        'DISTINCT' => 1,
        'DISTINCTROW' => 1,
        'HIGH_PRIORITY' => 2,
        'MAX_STATEMENT_TIME' => [
            3,
            'var=',
        ],
        'STRAIGHT_JOIN' => 4,
        'SQL_SMALL_RESULT' => 5,
        'SQL_BIG_RESULT' => 6,
        'SQL_BUFFER_RESULT' => 7,
        'SQL_CACHE' => 8,
        'SQL_NO_CACHE' => 8,
        'SQL_CALC_FOUND_ROWS' => 9,
    ];

    protected const STATEMENT_GROUP_OPTIONS = ['WITH ROLLUP' => 1];

    protected const STATEMENT_END_OPTIONS = [
        'FOR UPDATE' => 1,
        'LOCK IN SHARE MODE' => 1,
    ];

    /**
     * The clauses of this statement, in order.
     *
     * @see Statement::$clauses
     *
     * @var array<string, array<int, int|string>>
     * @psalm-var array<string, array{non-empty-string, (1|2|3)}>
     */
    public static $clauses = [
        'SELECT' => [
            'SELECT',
            2,
        ],
        // Used for options.
        '_OPTIONS' => [
            '_OPTIONS',
            1,
        ],
        // Used for selected expressions.
        '_SELECT' => [
            'SELECT',
            1,
        ],
        'INTO' => [
            'INTO',
            3,
        ],
        'FROM' => [
            'FROM',
            3,
        ],
        'FORCE' => [
            'FORCE',
            1,
        ],
        'USE' => [
            'USE',
            1,
        ],
        'IGNORE' => [
            'IGNORE',
            3,
        ],
        'PARTITION' => [
            'PARTITION',
            3,
        ],

        'JOIN' => [
            'JOIN',
            1,
        ],
        'FULL JOIN' => [
            'FULL JOIN',
            1,
        ],
        'INNER JOIN' => [
            'INNER JOIN',
            1,
        ],
        'LEFT JOIN' => [
            'LEFT JOIN',
            1,
        ],
        'LEFT OUTER JOIN' => [
            'LEFT OUTER JOIN',
            1,
        ],
        'RIGHT JOIN' => [
            'RIGHT JOIN',
            1,
        ],
        'RIGHT OUTER JOIN' => [
            'RIGHT OUTER JOIN',
            1,
        ],
        'NATURAL JOIN' => [
            'NATURAL JOIN',
            1,
        ],
        'NATURAL LEFT JOIN' => [
            'NATURAL LEFT JOIN',
            1,
        ],
        'NATURAL RIGHT JOIN' => [
            'NATURAL RIGHT JOIN',
            1,
        ],
        'NATURAL LEFT OUTER JOIN' => [
            'NATURAL LEFT OUTER JOIN',
            1,
        ],
        'NATURAL RIGHT OUTER JOIN' => [
            'NATURAL RIGHT JOIN',
            1,
        ],
        'WHERE' => [
            'WHERE',
            3,
        ],
        'GROUP BY' => [
            'GROUP BY',
            3,
        ],
        '_GROUP_OPTIONS' => [
            '_GROUP_OPTIONS',
            1,
        ],
        'HAVING' => [
            'HAVING',
            3,
        ],
        'ORDER BY' => [
            'ORDER BY',
            3,
        ],
        'LIMIT' => [
            'LIMIT',
            3,
        ],
        'PROCEDURE' => [
            'PROCEDURE',
            3,
        ],
        'UNION' => [
            'UNION',
            1,
        ],
        'EXCEPT' => [
            'EXCEPT',
            1,
        ],
        'INTERSECT' => [
            'INTERSECT',
            1,
        ],
        '_END_OPTIONS' => [
            '_END_OPTIONS',
            1,
        ],
        // These are available only when `UNION` is present.
        // 'ORDER BY'                      => ['ORDER BY', 3],
        // 'LIMIT'                         => ['LIMIT', 3],
    ];

    /**
     * Expressions that are being selected by this statement.
     *
     * @var Expression[]
     */
    public array $expr = [];

    /**
     * Tables used as sources for this statement.
     *
     * @var Expression[]
     */
    public array $from = [];

    /**
     * Index hints
     *
     * @var IndexHint[]|null
     */
    public $indexHints;

    /**
     * Partitions used as source for this statement.
     *
     * @var ArrayObj|null
     */
    public $partition;

    /**
     * Conditions used for filtering each row of the result set.
     *
     * @var Condition[]|null
     */
    public $where;

    /**
     * Conditions used for grouping the result set.
     *
     * @var GroupKeyword[]|null
     */
    public $group;

    /**
     * List of options available for the GROUP BY component.
     *
     * @var OptionsArray|null
     */
    public $groupOptions;

    /**
     * Conditions used for filtering the result set.
     *
     * @var Condition[]|null
     */
    public $having;

    /**
     * Specifies the order of the rows in the result set.
     *
     * @var OrderKeyword[]|null
     */
    public $order;

    /**
     * Conditions used for limiting the size of the result set.
     *
     * @var Limit|null
     */
    public $limit;

    /**
     * Procedure that should process the data in the result set.
     *
     * @var FunctionCall|null
     */
    public $procedure;

    /**
     * Destination of this result set.
     *
     * @var IntoKeyword|null
     */
    public $into;

    /**
     * Joins.
     *
     * @var JoinKeyword[]|null
     */
    public $join;

    /**
     * Unions.
     *
     * @var SelectStatement[]
     */
    public array $union = [];

    /**
     * The end options of this query.
     *
     * @see SelectStatement::STATEMENT_END_OPTIONS
     *
     * @var OptionsArray|null
     */
    public $endOptions;

    /**
     * Gets the clauses of this statement.
     *
     * @return array<string, array<int, int|string>>
     * @psalm-return array<string, array{non-empty-string, (1|2|3)}>
     */
    public function getClauses(): array
    {
        // This is a cheap fix for `SELECT` statements that contain `UNION`.
        // The `ORDER BY` and `LIMIT` clauses should be at the end of the
        // statement.
        if ($this->union !== []) {
            $clauses = static::$clauses;
            unset($clauses['ORDER BY'], $clauses['LIMIT']);
            $clauses['ORDER BY'] = [
                'ORDER BY',
                3,
            ];
            $clauses['LIMIT'] = [
                'LIMIT',
                3,
            ];

            return $clauses;
        }

        return static::$clauses;
    }

    /**
     * Gets a list of all aliases and their original names.
     *
     * @param string $database the name of the database
     *
     * @return array<string, array<string, array<string, array<string, array<string, string>|string|null>>|null>>
     */
    public function getAliases(string $database): array
    {
        if ($this->expr === [] || $this->from === []) {
            return [];
        }

        $retval = [];

        $tables = [];

        /**
         * Expressions that may contain aliases.
         * These are extracted from `FROM` and `JOIN` keywords.
         */
        $expressions = $this->from;

        // Adding expressions from JOIN.
        if (! empty($this->join)) {
            foreach ($this->join as $join) {
                $expressions[] = $join->expr;
            }
        }

        foreach ($expressions as $expr) {
            if (! isset($expr->table) || ($expr->table === '')) {
                continue;
            }

            $thisDb = isset($expr->database) && ($expr->database !== '') ?
                $expr->database : $database;

            if (! isset($retval[$thisDb])) {
                $retval[$thisDb] = [
                    'alias' => null,
                    'tables' => [],
                ];
            }

            if (! isset($retval[$thisDb]['tables'][$expr->table])) {
                $retval[$thisDb]['tables'][$expr->table] = [
                    'alias' => isset($expr->alias) && ($expr->alias !== '') ?
                        $expr->alias : null,
                    'columns' => [],
                ];
            }

            if (! isset($tables[$thisDb])) {
                $tables[$thisDb] = [];
            }

            $tables[$thisDb][$expr->alias] = $expr->table;
        }

        foreach ($this->expr as $expr) {
            if (! isset($expr->column, $expr->alias) || ($expr->column === '') || ($expr->alias === '')) {
                continue;
            }

            $thisDb = isset($expr->database) && ($expr->database !== '') ?
                $expr->database : $database;

            if (isset($expr->table) && ($expr->table !== '')) {
                $thisTable = $tables[$thisDb][$expr->table] ?? $expr->table;
                $retval[$thisDb]['tables'][$thisTable]['columns'][$expr->column] = $expr->alias;
            } else {
                foreach ($retval[$thisDb]['tables'] as &$table) {
                    $table['columns'][$expr->column] = $expr->alias;
                }
            }
        }

        return $retval;
    }
}
