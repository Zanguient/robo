//+------------------------------------------------------------------+
//|                                                 ROBOLAB_PHIL.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| VARIAVEIS                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Indicadores.mqh>

Indicadores IndicadoresOperacao();

int handle;
int curta = 17;
int media = 34;
int longa = 72;
int muitoLonga = 144;
int muito = 305;
int rsi ;
int vwap;
int obv;
double obvArray[];
//int hilo;
input int gain = 16;
input int loss = 11;
input double margem = 3;
input double candleForca = 3;
//input double tolSombra = 0;
input int rsiMinimoCompra = 50;
input int rsiMinimoVenda = 50;
input int stocsCompra = 50;
input int stocsVenda = 50;

double curtaArray[];
double mediaArray[];
double longaArray[];
double muitoLongaArray[];
double muitoArray[];
double RSIArray[];
double stochast[];
double signal[];
//double hiloArray[];
double vwapArray[];



double valorCurta;
double valorMedia;
double valorLonga;
double valorMuitoLonga;
double valorMuito;

MqlRates BarData[15];

double PrecoFechamentoPenultimoCandle = 1;    


bool mudouCandle = false;
bool ordemAberta = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//curta = iMA(_Symbol, _Period, curta, 0, MODE_EMA, PRICE_CLOSE);
media = iMA(_Symbol, _Period, media, 0, MODE_EMA, PRICE_CLOSE);
longa = iMA(_Symbol, _Period, longa, 0, MODE_EMA, PRICE_CLOSE);
muitoLonga = iMA(_Symbol, _Period, muitoLonga, 0, MODE_EMA, PRICE_CLOSE);
muito = iMA(_Symbol, _Period, muito, 0, MODE_EMA, PRICE_CLOSE);
rsi = iRSI(Symbol(), Period(), 14, PRICE_CLOSE);
handle = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, STO_LOWHIGH);
vwap = iCustom(Symbol(), Period(), "VWAP");
//hilo = iCustom(Symbol(), Period(), "HILO");
obv = iCustom(Symbol(), Period(), "OBV",VOLUME_TICK);
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


  
   
   ordemAberta = IndicadoresOperacao.OrdemAberta(_Symbol);
   
   CopyRates(_Symbol, _Period, 1, 15, BarData); 
   
   //PrecoTick = SymbolInfoDouble(Ativo, SYMBOL_LAST);

   mudouCandle = VerificarMudouCandle();
   
   //IndicadoresOperacao.StopGainMovel(2,10,10,_Symbol,SymbolInfoDouble(_Symbol, SYMBOL_BID));
   
   if (mudouCandle){
   
   
   
   if (ordemAberta)
   {       
        
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && (BarData[14].close < longaArray[0]            /*||  hiloArray[1] >  BarData[14].close*/   )  )
        {
        trade.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
        }
        else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && ( BarData[14].close >  longaArray[0] /*|| hiloArray[1] <  BarData[14].close*/))
        { 
        trade.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
        }
   
   }
   
   
   
   IndicadoresOperacao.horarioFecharPosicaoIndice("17:30", SymbolInfoDouble(_Symbol, SYMBOL_BID), _Symbol,1); 

   //ArraySetAsSeries(curtaArray, true);
   ArraySetAsSeries(mediaArray, true);
   ArraySetAsSeries(longaArray, true);
   ArraySetAsSeries(muitoLongaArray, true);
   ArraySetAsSeries(muitoArray, true);
   ArraySetAsSeries(RSIArray, true);
   ArraySetAsSeries(stochast, true);
   ArraySetAsSeries(signal, true);
   ArraySetAsSeries(vwapArray, true);
   
    ArraySetAsSeries(obvArray, true);
    CopyBuffer(obv, 0, 0, 3, obvArray);   
   //ArraySetAsSeries(hiloArray, true);
   
   //CopyBuffer(curta, 0, 0, 3, curtaArray);
   CopyBuffer(media, 0, 0, 16, mediaArray);
   CopyBuffer(longa, 0, 0, 3, longaArray); 
   CopyBuffer(muitoLonga, 0, 0, 3, muitoLongaArray); 
   CopyBuffer(muito, 0, 0, 3, muitoArray); 
   CopyBuffer(rsi, 0, 0, 3, RSIArray); 
   CopyBuffer(handle, 0, 0, 3, stochast);
   CopyBuffer(handle, 1, 0, 3, signal);
   CopyBuffer(vwap, 0, 0, 3, vwapArray); 
   //CopyBuffer(hilo, 0, 0, 3, hiloArray); 
   
   
   //valorCurta = curtaArray[1];
   valorMedia = mediaArray[1];
   valorLonga = longaArray[1];
   valorMuitoLonga = muitoLongaArray[1];
   valorMuito = muitoArray[1];
   
   
   double tamanhoCandle = 0;
   double sombraInf = 0;
   double sombraSup = 0;
   string sinalCandle = "";
   //string sentidoSombra = "";
   //double razao = 0;
   
   if (BarData[14].close > BarData[14].open){
   tamanhoCandle = BarData[14].close - BarData[14].open;
   sombraSup = BarData[14].high - BarData[14].close;
   sombraInf = BarData[14].open - BarData[14].low;
   sinalCandle = "C";
   
   }
   else {
   
   tamanhoCandle = BarData[14].open - BarData[14].close;
   sombraSup = BarData[14].high - BarData[14].open;
   sombraInf = BarData[14].close - BarData[14].low;
   sinalCandle = "V";
   
   
   }
   
   /*double tamanhoCandleDois = 0;
   double sombraInfDois = 0;
   double sombraSupDois = 0;
   string sinalCandleDois = "";
   string sentidoSombraDois = "";
   double razaoDois = 0;
   
   if (BarData[13].close > BarData[13].open){
   tamanhoCandleDois = BarData[13].close - BarData[13].open;
   sombraSupDois = BarData[13].high - BarData[13].close;
   sombraInfDois = BarData[13].open - BarData[13].low;
   sinalCandleDois = "C";
   
   }
   else {
   
   tamanhoCandleDois = BarData[13].open - BarData[13].close;
   sombraSupDois = BarData[13].high - BarData[13].open;
   sombraInfDois = BarData[13].close - BarData[13].low;
   sinalCandleDois = "V";
   
   
   }*/
   
  
   
   //COMPRA
   if (
   
   //(
   //(curtaArray[0] > mediaArray[0] && curtaArray[1] < mediaArray[1]  )||
   //(curtaArray[0] > longaArray[0] && curtaArray[1] < longaArray[1])||
   //(curtaArray[0] > muitoLongaArray[0] && curtaArray[1] < muitoLongaArray[1])||
   //(mediaArray[0] > longaArray[0] && mediaArray[1] < longaArray[1])||
   //(mediaArray[0] > muitoLongaArray[0] && mediaArray[1] < muitoLongaArray[1])
   (BarData[14].close > mediaArray[0] &&  BarData[14].close - mediaArray[0] < margem && BarData[14].close - mediaArray[0] > 0)
   //(longaArray[0] > muitoLongaArray[0] && longaArray[1] < muitoLongaArray[1])   
   //) 
   &&
   //(curtaArray[0] > mediaArray[0] &&  mediaArray[0] > longaArray[0]  && longaArray[0] > muitoLongaArray[0])
   //( mediaArray[0] > muitoLongaArray[0]  && muitoLongaArray[0] < muitoArray[0])
   (mediaArray[0] > longaArray[0]  && longaArray[0] > muitoLongaArray[0] && muitoLongaArray[0] > muitoArray[0])
   &&
   (!ordemAberta)
   &&
   procurarRompimento("Compra")
   &&
   IndicadoresOperacao.horaOperar("17:00")
   &&
   SymbolInfoDouble(_Symbol, SYMBOL_LAST) - mediaArray[0] <= margem
   //&&   RSIArray[1] > rsiMinimoCompra
   //&&   signal[1] < stocsCompra
   &&   SymbolInfoDouble(_Symbol, SYMBOL_LAST) > vwapArray[1]
   && (sinalCandle != "C" && tamanhoCandle < candleForca )
   && obvArray[1] < obvArray[2]
   )
   {
   
   //if (sombraInf > sombraSup || sombraSup - sombraInf <= tolSombra )  sentidoSombra = "+";
   //else  sentidoSombra = "-";   

   double precoReferencia = BarData[14].high +1;
          datetime  expiration=TimeTradeServer()+PeriodSeconds(PERIOD_M5);
   
   
   trade.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_ASK) - loss, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + gain, tamanhoCandle + ":" + sombraSup + ":" + sombraInf + ":" + sinalCandle + ":C:" );
   
  //trade.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration);
   
   }
   //VENDA
   if (
   
   //(
   //(curtaArray[0] < mediaArray[0] && curtaArray[1] > mediaArray[1]  )||
   //(curtaArray[0] < longaArray[0] && curtaArray[1] > longaArray[1])||
   //(curtaArray[0] < muitoLongaArray[0] && curtaArray[1] > muitoLongaArray[1])||
   //(mediaArray[0] < longaArray[0] && mediaArray[1] > longaArray[1])||
   //(mediaArray[0] < muitoLongaArray[0] && mediaArray[1] > muitoLongaArray[1])
   (BarData[14].close < mediaArray[0] && mediaArray[0] - BarData[14].close < margem && mediaArray[0] - BarData[14].close > 0)
   //(longaArray[0] < muitoLongaArray[0] && longaArray[1] > muitoLongaArray[1])   
   //) 
   &&
   //(curtaArray[0] < mediaArray[0] &&  mediaArray[0] < longaArray[0]  && longaArray[0] < muitoLongaArray[0])
   // ( mediaArray[0] < muitoLongaArray[0]  && muitoLongaArray[0] < muitoArray[0])
   (mediaArray[0] < longaArray[0]  && longaArray[0] < muitoLongaArray[0] && muitoLongaArray[0] < muitoArray[0])
   &&
   (!ordemAberta)
   &&
   procurarRompimento("Venda")
   &&
   IndicadoresOperacao.horaOperar("17:00")
   &&
   mediaArray[0] - SymbolInfoDouble(_Symbol, SYMBOL_LAST) <= margem
   //&&   RSIArray[1] < rsiMinimoVenda
   //&&   signal[1] > stocsVenda
   &&   SymbolInfoDouble(_Symbol, SYMBOL_LAST) < vwapArray[1]
   && (sinalCandle != "V" && tamanhoCandle < candleForca)
    && obvArray[1] < obvArray[2]
   )
   {
  
  
  double precoReferencia = BarData[14].low ;
          datetime  expiration=TimeTradeServer()+PeriodSeconds(PERIOD_M5);
   
   
   trade.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_BID) + loss, SymbolInfoDouble(_Symbol, SYMBOL_BID) - gain, tamanhoCandle + ":" + sombraSup + ":" + sombraInf + ":" + sinalCandle + ":V:" );
 
   //trade.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration,":" + sentidoSombra);
   
   // trade.SellStop(1,precoReferencia,_Symbol,precoReferencia + loss,precoReferencia - gain,ORDER_TIME_SPECIFIED,expiration);
   
   } 
   
   
   
   }
   





   
  }
//+------------------------------------------------------------------+


bool VerificarMudouCandle()
{
    if (BarData[14].close != PrecoFechamentoPenultimoCandle)
    {
        PrecoFechamentoPenultimoCandle = BarData[14].close;
        return true;
    }

    else return false;
}

bool procurarRompimento(string sinal){



        int x;

        for (x = 0; x < 15; x++)
        {
        
           if (mediaArray[x + 1] < BarData[14 - x].high && sinal == "Venda")
           {
           
           return false;
           
           }
           
           if (mediaArray[x + 1] > BarData[14 - x].low && sinal == "Compra")
           {
           
           return false;
           
           }
        }
        
        return true;

}