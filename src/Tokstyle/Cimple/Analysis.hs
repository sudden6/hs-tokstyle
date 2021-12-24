module Tokstyle.Cimple.Analysis
    ( analyse
    , analyseGlobal
    ) where

import           Data.Text                                (Text)
import           Language.Cimple                          (Lexeme, Node (..))

import qualified Tokstyle.Cimple.Analysis.ForLoops        as ForLoops
import qualified Tokstyle.Cimple.Analysis.FuncPrototypes  as FuncPrototypes
import qualified Tokstyle.Cimple.Analysis.FuncScopes      as FuncScopes
import qualified Tokstyle.Cimple.Analysis.GlobalFuncs     as GlobalFuncs
import qualified Tokstyle.Cimple.Analysis.LoggerCalls     as LoggerCalls
import qualified Tokstyle.Cimple.Analysis.LoggerNoEscapes as LoggerNoEscapes
--import qualified Tokstyle.Cimple.Analysis.VarUnusedInScope as VarUnusedInScope

import qualified Tokstyle.Cimple.Analysis.DeclaredOnce    as DeclaredOnce
import qualified Tokstyle.Cimple.Analysis.DeclsHaveDefns  as DeclsHaveDefns
import qualified Tokstyle.Cimple.Analysis.DocComments     as DocComments


type TranslationUnit = (FilePath, [Node () (Lexeme Text)])

analyse :: TranslationUnit -> [Text]
analyse tu = concatMap ($ tu)
    [ ForLoops.analyse
    , FuncPrototypes.analyse
    , FuncScopes.analyse
    , GlobalFuncs.analyse
    , LoggerCalls.analyse
    , LoggerNoEscapes.analyse
    --, VarUnusedInScope.analyse
    ]

analyseGlobal :: [TranslationUnit] -> [Text]
analyseGlobal tus = concatMap ($ tus)
    [ DeclaredOnce.analyse
    , DeclsHaveDefns.analyse
    , DocComments.analyse
    ]
