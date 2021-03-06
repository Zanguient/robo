//+------------------------------------------------------------------+
//|                                                 ROBOLAB_PHIL.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "Este robo tem como objetivo operar pullback perto da media de 34"
#property description "Regra 1: Na compra as medias 34,72,144,305 estarem nesta ordem de cima para baixo"
#property description "Regra 1: Na venda as medias 34,72,144,305 estarem nesta ordem de baixo para cima"
#property description "Regra 2: Nao ter rompido a media de 34 nos ultimos 14 periodos"
#property description "Regra 3: Nao abre duas ordens se ocorrer outro sinal"
#property description "Regra 4: Nao nenhuma ordem após as 17hrs"
#property description "Regra 5: O tamanho do candle do sinal nao pode ser maior que o parametrizado"
#property description "Regra 6: O candle de sinal nao pode ter fechado acima/abaixo da media de 34"
//+------------------------------------------------------------------+
//| VARIAVEIS                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Indicadores.mqh>

Indicadores IndicadoresOperacao();


// INPUT

//input bool usarRSI = false;
//input int rsiMinimoCompra = 50;
//input int rsiMinimoVenda = 50;

//input bool usarVWAP = false;
//input bool usarOBV = false;
//input bool STOCS = false;

int media = 34;
int longa = 72;
int muitoLonga = 144;
int muito = 305;

int rsi ;
int vwap;
int obv;
int handle;

input int gain = 16;
input int loss = 11;
input double margem = 3;
input double candleForca = 3;

//input int stocsCompra = 50;
//input int stocsVenda = 50;

double mediaArray[];
double longaArray[];
double muitoLongaArray[];
double muitoArray[];
double RSIArray[];
double stochast[];
double signal[];
double hiloArray[];
double vwapArray[];
double obvArray[];

MqlRates BarData[15];

double PrecoFechamentoPenultimoCandle = 1;


bool mudouCandle = false;
bool ordemAberta = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

    
    media = iMA(_Symbol, _Period, media, 0, MODE_EMA, PRICE_CLOSE);
    longa = iMA(_Symbol, _Period, longa, 0, MODE_EMA, PRICE_CLOSE);
    muitoLonga = iMA(_Symbol, _Period, muitoLonga, 0, MODE_EMA, PRICE_CLOSE);
    muito = iMA(_Symbol, _Period, muito, 0, MODE_EMA, PRICE_CLOSE);
    //rsi = iRSI(Symbol(), Period(), 14, PRICE_CLOSE);
    //handle = iStochastic(Symbol(), Period(), 5, 3, 3, MODE_SMA, STO_LOWHIGH);
    //vwap = iCustom(Symbol(), Period(), "VWAP");    
    //obv = iCustom(Symbol(), Period(), "OBV",VOLUME_TICK);
    return (INIT_SUCCEEDED);
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

    mudouCandle = VerificarMudouCandle();    

    if (mudouCandle)
    {

        if (ordemAberta)
        {

            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && (BarData[14].close < longaArray[0]  ))
            {
                trade.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && (BarData[14].close > longaArray[0] ))
            {
                trade.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
            }

        }

        IndicadoresOperacao.horarioFecharPosicaoIndice("17:30", SymbolInfoDouble(_Symbol, SYMBOL_BID), _Symbol, 1);

        
        ArraySetAsSeries(mediaArray, true);
        ArraySetAsSeries(longaArray, true);
        ArraySetAsSeries(muitoLongaArray, true);
        ArraySetAsSeries(muitoArray, true);
        
        CopyBuffer(media, 0, 0, 16, mediaArray);
        CopyBuffer(longa, 0, 0, 3, longaArray);
        CopyBuffer(muitoLonga, 0, 0, 3, muitoLongaArray);
        CopyBuffer(muito, 0, 0, 3, muitoArray);        
        
        
        //ArraySetAsSeries(RSIArray, true);
        //CopyBuffer(rsi, 0, 0, 3, RSIArray);         
        
        //ArraySetAsSeries(stochast, true);
        //ArraySetAsSeries(signal, true);        
        //CopyBuffer(handle, 0, 0, 3, stochast);
        //CopyBuffer(handle, 1, 0, 3, signal);
        
        //ArraySetAsSeries(vwapArray, true);
        //CopyBuffer(vwap, 0, 0, 3, vwapArray);

        //ArraySetAsSeries(obvArray, true);
        //CopyBuffer(obv, 0, 0, 3, obvArray);     

        double tamanhoCandle = 0;
        double sombraInf = 0;
        double sombraSup = 0;
        string sinalCandle = "";       
        

        if (BarData[14].close > BarData[14].open)
        {
            tamanhoCandle = BarData[14].close - BarData[14].open;
            sombraSup = BarData[14].high - BarData[14].close;
            sombraInf = BarData[14].open - BarData[14].low;
            sinalCandle = "C";
        }
        else
        {
            tamanhoCandle = BarData[14].open - BarData[14].close;
            sombraSup = BarData[14].high - BarData[14].open;
            sombraInf = BarData[14].close - BarData[14].low;
            sinalCandle = "V";
        }        

        //COMPRA
        if ( IndicadoresOperacao.horaOperar("17:00")
        &&   !ordemAberta
        &&  (mediaArray[0] > longaArray[0] && longaArray[0] > muitoLongaArray[0] && muitoLongaArray[0] > muitoArray[0])
        //&&   obvArray[1] < obvArray[2]
        //&&   RSIArray[1] > rsiMinimoCompra
        //&&   signal[1] < stocsCompra
        //&&   SymbolInfoDouble(_Symbol, SYMBOL_LAST) > vwapArray[1]
        &&  (BarData[14].close > mediaArray[0] && BarData[14].close - mediaArray[0] < margem && BarData[14].close - mediaArray[0] > 0)        
        &&  procurarRompimento("Compra")        
        &&  SymbolInfoDouble(_Symbol, SYMBOL_LAST) - mediaArray[0] <= margem        
        && (sinalCandle != "C" && tamanhoCandle < candleForca)        
        )
        {            
            //trade.BuyStop(1,precoReferencia,_Symbol,precoReferencia - loss,precoReferencia + gain,ORDER_TIME_SPECIFIED,expiration);  
            //double precoReferencia = BarData[14].high + 1;
            //datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M5);
            trade.Buy(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), SymbolInfoDouble(_Symbol, SYMBOL_ASK) - loss, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + gain, tamanhoCandle + ":" + sombraSup + ":" + sombraInf + ":" + sinalCandle + ":C:");            

        }
        //VENDA
        if ( !ordemAberta       
        && IndicadoresOperacao.horaOperar("17:00")      
        && (mediaArray[0] < longaArray[0] && longaArray[0] < muitoLongaArray[0] && muitoLongaArray[0] < muitoArray[0]) 
        //&& obvArray[1] < obvArray[2]
        //&&   RSIArray[1] < rsiMinimoVenda
        //&&   signal[1] > stocsVenda
        //&& SymbolInfoDouble(_Symbol, SYMBOL_LAST) < vwapArray[1]
        && (BarData[14].close < mediaArray[0] && mediaArray[0] - BarData[14].close < margem && mediaArray[0] - BarData[14].close > 0)                   
        && procurarRompimento("Venda")        
        && mediaArray[0] - SymbolInfoDouble(_Symbol, SYMBOL_LAST) <= margem                
        && (sinalCandle != "V" && tamanhoCandle < candleForca)    
        )
        {
            //double precoReferencia = BarData[14].low;
            //datetime expiration = TimeTradeServer() + PeriodSeconds(PERIOD_M5);            
            // trade.SellStop(1,precoReferencia,_Symbol,precoReferencia + loss,precoReferencia - gain,ORDER_TIME_SPECIFIED,expiration);
            trade.Sell(1, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), SymbolInfoDouble(_Symbol, SYMBOL_BID) + loss, SymbolInfoDouble(_Symbol, SYMBOL_BID) - gain, tamanhoCandle + ":" + sombraSup + ":" + sombraInf + ":" + sinalCandle + ":V:");         
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

bool procurarRompimento(string sinal)
{

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