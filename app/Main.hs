module Main where

-- import Lib
-- import qualified Data.Either                   as E
import qualified Data.List                     as List
-- import           Data.Map.Strict               ((!?))
-- import qualified Data.Map.Strict               as Map
-- import qualified Data.Maybe                    as May
-- import qualified Data.Text.Lazy                as TLazy
import qualified Safe                          as Safe
-- import qualified System.Console.Haskeline      as HLine
import qualified System.Environment            as Env
-- import qualified System.Environment            as Env
import qualified Text.Parsec                   as P
import           Text.ParserCombinators.Parsec

makeSrc :: Int -> [String] -> [String] -> [String]
makeSrc varNum inputs accm =
  case Safe.headMay inputs of
    Just "+" -> makeSrc (varNum + 4) (tail inputs)
                (accm
                  ++ ("  %" ++ show varNum ++ " = load i32, i32* %" ++ show (varNum - 2) ++ ", align 4")
                  :  ("  %" ++ show (varNum + 1) ++ " = load i32, i32* %" ++ show (varNum - 1) ++ ", align 4")
                  :  ("  %" ++ show (varNum + 2) ++ " = add nsw i32 %" ++ show varNum ++ ", %" ++ show (varNum + 1))
                  :   ""
                  :  ("  %" ++ show (varNum + 3) ++ " = alloca i32, align 4")
                  :  ("  store i32 %" ++ show (varNum + 2) ++ ", i32* %" ++ show (varNum + 3) ++ ", align 4")
                  :"":"":[])

    Just "-" -> makeSrc (varNum + 4) (tail inputs)
                (accm
                  ++ ("  %" ++ show varNum ++ " = load i32, i32* %" ++ show (varNum - 2) ++ ", align 4")
                  :  ("  %" ++ show (varNum + 1) ++ " = load i32, i32* %" ++ show (varNum - 1) ++ ", align 4")
                  :  ("  %" ++ show (varNum + 2) ++ " = sub nsw i32 %" ++ show varNum ++ ", %" ++ show (varNum + 1))
                  :   ""
                  :  ("  %" ++ show (varNum + 3) ++ " = alloca i32, align 4")
                  :  ("  store i32 %" ++ show (varNum + 2) ++ ", i32* %" ++ show (varNum + 3) ++ ", align 4")
                  :"":"":[])

    Just num -> makeSrc (varNum + 1) (tail inputs)
                (accm
                  ++ ("  %" ++ show varNum ++ " = alloca i32, align 4")
                  :  ("  store i32 " ++ num ++ ", i32* %" ++ show varNum ++ ", align 4")
                  :"":"":[])

    Nothing -> (accm
               ++ ("  %" ++ show varNum ++ " = load i32, i32* %" ++ show (varNum - 1) ++ ", align 4")
               :  ("  ret i32 %" ++ show varNum)
               :   "}":[])


symbol :: Parser Char
symbol = oneOf "+-"

parser :: Parser [String]
parser = do
  num1 <- spaces >> many1 digit
  rest <- (do
              addsub <- spaces >> symbol
              number <- spaces >> many1 digit
              return $ number:[[addsub]])
          `manyTill` eof
  return $ [num1] ++ foldl1 (++) rest

main :: IO ()
main = do
  input <- head <$> Env.getArgs
  case parse parser "" input of
    Right val ->
      mapM_ putStrLn
      $ makeSrc 1 val
      [ "define i32 @main() {"]
    Left err  -> putStrLn $ show err

  -- mapM_ putStrLn
  --   $ makeSrc 1 input
  --   [ "define i32 @main() {"]
