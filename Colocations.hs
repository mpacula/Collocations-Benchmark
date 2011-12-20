-- (c) Bas van Dijk 2011 (https://github.com/basvandijk)

import Prelude hiding (unlines)
import Data.Hashable (Hashable)
import Data.Int (Int64)
import Data.Monoid (mconcat)
import Data.List (foldl', sort, intersperse)
import qualified Data.HashMap.Strict as H
import qualified Data.HashSet as HS
import qualified Data.List.Split as S
import qualified Data.Text              as T
import qualified Data.Text.IO           as TIO
import qualified Data.Text.Lazy.Builder as TLB
import qualified Data.Text.Lazy.IO      as TLIO

type Sentence   = T.Text
type Paragraph  = [Sentence]
type Word       = T.Text
type Pair       = (Word, Word)
type CountTable = H.HashMap Word (H.HashMap Word Count)
type Count      = Int64

main :: IO ()
main = TIO.getContents >>=
         TLIO.putStr . TLB.toLazyText
                     . unlines
                     . map serialize
                     . sort
                     . counts

unlines :: [TLB.Builder] -> TLB.Builder
unlines = mconcat . intersperse (TLB.singleton '\n')

serialize :: (Word, Word, Count) -> TLB.Builder
serialize (w1, w2, c) = mconcat [ TLB.fromString (show c)
                                , TLB.singleton  '\t'
                                , TLB.fromText   w1
                                , TLB.singleton  ' '
                                , TLB.fromText   w2
                                ]

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
    helper (x:rs@(y:z:_)) = sentenceCounts y [x,z] ++ helper rs

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
