{-# LANGUAGE OverloadedStrings #-}
module Tokstyle.Linter.TypeCheckSpec where

import           Test.Hspec          (Spec, it, shouldBe)

import           Tokstyle.Linter     (analyse)
import           Tokstyle.LinterSpec (mustParse)


spec :: Spec
spec = do
    it "should not crash on input" $ do
        ast <- mustParse
            [ "int a(void) {"
            , "  int i;"
            , "  put_int(i);"
            , "}"
            ]
        analyse ["type-check"] ("test.c", ast)
            `shouldBe`
            []
