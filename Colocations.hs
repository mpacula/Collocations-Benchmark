-- (c) Bas van Dijk 2011 (https://github.com/basvandijk)

{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (mapM_)
import Data.Functor ((<$>))
import Data.Hashable (Hashable)
import Data.Int (Int64)
import Data.List (foldl', sort)
import Data.Monoid (mappend)
import System.IO (stdin)
import qualified Data.HashMap.Strict as H
import qualified Data.HashSet as HS
import qualified Data.List.Split as S
import qualified Data.Text as T
import qualified Data.Text.IO as T

type Sentence   = T.Text
type Paragraph  = [Sentence]
type Word       = T.Text
type Pair       = (Word, Word)
type CountTable = H.HashMap T.Text (H.HashMap T.Text Count)
type Count      = Int64

main :: IO ()
main = T.interact $ T.unlines . map serialize . sort . counts

serialize :: (Word, Word, Count) -> T.Text
serialize (w1, w2, c) = T.concat [T.pack (show c), "\t", w1, " ", w2]

counts :: T.Text -> [(Word, Word, Count)]
counts = convert . countTable . concatMap pairs . paragraphs . T.lines

convert :: CountTable -> [(Word, Word, Count)]
convert ct = [ (w1, w2, c)
             | (w1, w2Map) <- H.toList ct
             , (w2, c)     <- H.toList w2Map
             ]

paragraphs :: [Sentence] -> [Paragraph]
paragraphs = S.split paragraphSplitter . map T.strip
    where
      paragraphSplitter :: S.Splitter Sentence
      paragraphSplitter = S.dropFinalBlank $ 
                          S.dropInitBlank  $ 
                          S.condense       $ 
                          S.dropDelims     $ 
                          S.whenElt T.null

pairs :: Paragraph -> [Pair]
pairs [_] = []
pairs sentences = helper ([]:map T.words sentences)
  where
    helper [] = []
    helper [_] = []
    helper (x:y:[]) = sentenceCounts y [x]
    helper (x:rs@(y:z:rest)) = sentenceCounts y [x,z] ++ helper rs

sentenceCounts :: [Word] -> [[Word]] -> [Pair]
sentenceCounts sentence context =
    [ (w1, w2) 
    | w1 <- sentence
    , w2 <- fastNub $ concat context
    ]

fastNub ::(Eq a, Hashable a) => [a] -> [a]
fastNub = HS.toList . HS.fromList

countTable :: [Pair] -> CountTable
countTable = foldl' ins H.empty
    where
      ins ct (w1, w2) = H.insertWith combine w1 (H.singleton w2 1) ct
          where
            combine _ w1Map = H.insertWith (+) w2 1 w1Map
