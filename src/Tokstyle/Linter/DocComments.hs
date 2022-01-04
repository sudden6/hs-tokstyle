{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData        #-}
module Tokstyle.Linter.DocComments (analyse) where

import qualified Control.Monad.State.Strict  as State
import           Data.Fix                    (Fix (..))
import           Data.Text                   (Text)
import qualified Data.Text                   as Text
import           Language.Cimple             (AlexPosn (..), AstActions',
                                              Lexeme (..), LexemeClass (..),
                                              Node, NodeF (..), defaultActions',
                                              doLexeme, doNode, traverseAst)
import           Language.Cimple.Diagnostics (HasDiagnostics (..), warn')
import           Language.Cimple.Pretty      (ppTranslationUnit)


data Linter = Linter
    { diags :: [Text]
    , docs  :: [(Text, (FilePath, Node (Lexeme Text)))]
    }

empty :: Linter
empty = Linter [] []

instance HasDiagnostics Linter where
    addDiagnostic diag l@Linter{diags} = l{diags = addDiagnostic diag diags}


linter :: AstActions' Linter
linter = defaultActions'
    { doNode = \file node act ->
        case unFix node of
            Commented doc (Fix (FunctionDecl _ (Fix (FunctionPrototype _ (L _ IdVar fname) _)))) -> do
                checkCommentEquals file doc fname
                return node

            Commented doc (Fix (FunctionDefn _ (Fix (FunctionPrototype _ (L _ IdVar fname) _)) _)) -> do
                checkCommentEquals file doc fname
                return node

            {-
            Commented _ n -> do
                warn' file node . Text.pack . show $ n
                act
            -}

            FunctionDefn{} -> return node
            _ -> act
    }
  where
    tshow = Text.pack . show

    removeSloc :: Node (Lexeme Text) -> Node (Lexeme Text)
    removeSloc = flip State.evalState () . traverseAst defaultActions'
      { doLexeme = \_ (L _ c t) _ -> pure $ L (AlexPn 0 0 0) c t
      }

    checkCommentEquals file doc fname = do
        l@Linter{docs} <- State.get
        case lookup fname docs of
            Nothing -> State.put l{docs = (fname, (file, doc)):docs}
            Just (_, doc') | removeSloc doc == removeSloc doc' -> return ()
            Just (file', doc') -> do
                warn' file doc $ "comment on definition of `" <> fname
                    <> "' does not match declaration:\n"
                    <> tshow (ppTranslationUnit [doc])
                warn' file' doc' $ "mismatching comment found here:\n"
                    <> tshow (ppTranslationUnit [doc'])

analyse :: [(FilePath, [Node (Lexeme Text)])] -> [Text]
analyse = reverse . diags . flip State.execState empty . traverseAst linter . reverse
