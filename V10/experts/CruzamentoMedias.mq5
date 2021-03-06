//+------------------------------------------------------------------+
//|                                                       HYGOR2.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>

CTrade operacao;

enum Medias  // Enumeração de constantes nomeadas
   {
   Media_2 = 2,
   Media_3 = 3,
   Media_4 = 4,
   Media_5 = 5,
   Media_8 = 8,
   Media_9 = 9,
   Media_10 = 10,
   Media_17 = 17,
   Media_20 = 20,
   Media_21 = 21,
   Media_34 = 34,
   Media_40 = 40, 
   Media_50 = 50,
   Media_72 = 72,
   Media_80 = 80,
   Media_144 = 144,
   Media_200 = 200,
   Media_305 = 305,
   Media_400 = 400,
   Media_618 = 618
   };

bool operando = true;

input double gain = 2;
input double loss = 5;
input Medias rapida = Media_2;
input Medias lenta = Media_3;
input Medias super = Media_3;
input string horario = "17:00";

int mRapida;
int mLonga;
int mSuper;
double PrecoFechamentoPenultimoCandle = 1;

double MediaCurtaArray[];   
double MediaLongaArray[]; 
double MediaSuperArray[]; 

MqlRates BarData[1];

int OnInit()
  {
//---
   mRapida = iMA(_Symbol, _Period, rapida, 0, MODE_EMA, PRICE_CLOSE);
   mLonga = iMA(_Symbol, _Period, lenta,0, MODE_EMA, PRICE_CLOSE);
   mSuper = iMA(_Symbol, _Period, super,0, MODE_EMA, PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
  CopyRates(_Symbol, _Period, 1, 1, BarData);
   
  ArraySetAsSeries(MediaCurtaArray, true);    
  ArraySetAsSeries(MediaLongaArray, true);
  ArraySetAsSeries(MediaSuperArray, true);
    
  CopyBuffer(mRapida, 0, 0, 3, MediaCurtaArray);    
  CopyBuffer(mLonga, 0, 0, 3, MediaLongaArray);  
  CopyBuffer(mSuper, 0, 0, 3, MediaSuperArray); 
  
  if (VerificarMudouCandle()){  
  
        operando = false;
        
        
        if  (  MediaCurtaArray[0] >  MediaLongaArray [0] &&  MediaCurtaArray[1] <  MediaLongaArray [1] && horaOperar(horario) && !operando && SymbolInfoDouble(_Symbol, SYMBOL_LAST) > MediaSuperArray[0]){  
        
        
        // datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M30);        
         //double precoReferencia = BarData[0].high;
        // operacao.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration);  
         operacao.Buy(1,_Symbol,_Period, SymbolInfoDouble(_Symbol, SYMBOL_LAST) - loss,SymbolInfoDouble(_Symbol, SYMBOL_LAST) + gain);  
         operando = true;  
        }
        
        else if  (  MediaCurtaArray[0] <  MediaLongaArray [0] &&  MediaCurtaArray[1] >  MediaLongaArray [1] && horaOperar(horario) && !operando && SymbolInfoDouble(_Symbol, SYMBOL_LAST) < MediaSuperArray[0]){  
          
          
          
        
        // datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M30);        
        //double precoReferencia = BarData[0].low;
        
       // operacao.SellStop(1,precoReferencia,_Symbol,precoReferencia + loss,precoReferencia - gain,ORDER_TIME_SPECIFIED,expiration);
          
        operacao.Sell(1,_Symbol,_Period, SymbolInfoDouble(_Symbol, SYMBOL_LAST) + loss,SymbolInfoDouble(_Symbol, SYMBOL_LAST) - gain);    
          operando = true;  
        }   
          
       
  }
  
  
  
  
  
  
   
}
//+------------------------------------------------------------------+


bool VerificarMudouCandle()
{
    if (BarData[0].close != PrecoFechamentoPenultimoCandle)
    {
        PrecoFechamentoPenultimoCandle = BarData[0].close;
        return true;
    }

    else return false;
}

bool horaOperar(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);    
    
    horaCorrente = StringToTime(   "2019.01.01 " + horaCorrenteStr);    

    if ( StringToTime(   "2019.01.01 " + horaCorrenteStr)  <= StringToTime(   "2019.01.01 " + inicioPrimeiroPeriodo) )
      {             
        return true;        
      }
    else
      {
        return false;
      }

}