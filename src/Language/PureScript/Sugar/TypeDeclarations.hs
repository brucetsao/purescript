-----------------------------------------------------------------------------
--
-- Module      :  Language.PureScript.Sugar.TypeDeclarations
-- Copyright   :  (c) Phil Freeman 2013
-- License     :  MIT
--
-- Maintainer  :  Phil Freeman <paf31@cantab.net>
-- Stability   :  experimental
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module Language.PureScript.Sugar.TypeDeclarations (
    desugarTypeDeclarations,
    desugarTypeDeclarationsModule
) where

import Control.Applicative
import Control.Monad.Error.Class
import Control.Monad (forM)

import Language.PureScript.Declarations
import Language.PureScript.Values

desugarTypeDeclarationsModule :: [Module] -> Either String [Module]
desugarTypeDeclarationsModule ms = forM ms $ \(Module name ds) -> Module name <$> desugarTypeDeclarations ds

desugarTypeDeclarations :: [Declaration] -> Either String [Declaration]
desugarTypeDeclarations (TypeDeclaration name ty : ValueDeclaration name' [] Nothing val : rest) | name == name' =
  desugarTypeDeclarations (ValueDeclaration name [] Nothing (TypedValue True val ty) : rest)
desugarTypeDeclarations (TypeDeclaration name _ : _) = throwError $ "Orphan type declaration for " ++ show name
desugarTypeDeclarations (d:ds) = (:) d <$> desugarTypeDeclarations ds
desugarTypeDeclarations [] = return []
