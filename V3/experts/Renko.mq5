#property copyright "Copyright 2019, Leonardo Bezerra."
#property link      "leonardoab89@gmail.com"
#property version   "1.0"
#property description "Renko"
#include <RenkoCharts.mqh>
#include <Indicadores.mqh>

/* ======================================== RENKO =============================================================*/

// Inputs
input string RenkoSymbol = "";                              //Symbol (Default = current)
input ENUM_RENKO_TYPE RenkoType = RENKO_TYPE_TICKS;         //Type
input double RenkoSize = 4;                                //Brick Size (Ticks, Pips or Points)
input bool RenkoWicks = true;                               //Show Wicks
input ENUM_RENKO_WINDOW RenkoWindow = RENKO_CURRENT_WINDOW; //Window
input int RenkoTimer = 1000;                                //Timer in milliseconds (0 = Off)
input bool ModoBackTeste = true;                            //Modo Backteste

/* ============================================================================================================*/


int posicoes[5];

input int mediaRapida = 144; // Média Rapida
input int media = 50;             // Média
input int mediaLonga = 100;       // Média Longa

double valorPorTick[6];

int ValorMediaCurtaTick = 0;

MqlRates BarData[1];

double PrecoTick;
double PrecoFechamentoUltimoCandle;
double PrecoAberturaUltimoCandle;
double PrecoFechamentoPenultimoCandle = 1;

bool mudouCandle = false;

/* ============================================================================================================*/


// Renko Charts
RenkoCharts RenkoOffline();
Indicadores IndicadoresOperacao();
string original_symbol, custom_symbol;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  if (!ModoBackTeste) { 
   //Get Symbol
      if(RenkoSymbol!="")
         original_symbol = RenkoSymbol;
   //Check Period
      if(RenkoWindow == RENKO_CURRENT_WINDOW && ChartPeriod(0) != PERIOD_M1)
        {
         MessageBox("Renko must be M1 period!", __FILE__, MB_OK);
         ChartSetSymbolPeriod(0, _Symbol, PERIOD_M1);
         return(INIT_SUCCEEDED);
        }
   //Check Symbol
      if(!RenkoOffline.ValidateSymbol(original_symbol))
        {
         MessageBox("Invalid symbol error. Select a valid symbol!", __FILE__, MB_OK);
         return(INIT_FAILED);
        }
   //Setup Renko
      if(!RenkoOffline.Setup(original_symbol, RenkoType, RenkoSize, RenkoWicks))
        {
         MessageBox("Renko setup error. Check error log!", __FILE__, MB_OK);
         return(INIT_FAILED);
        }
   //Create Custom Symbol
      RenkoOffline.CreateCustomSymbol();
      RenkoOffline.ClearCustomSymbol();
      custom_symbol = RenkoOffline.GetSymbolName();
   //Load History
      RenkoOffline.UpdateRates();
      RenkoOffline.ReplaceCustomSymbol();   
   //Chart Setup
      RenkoOffline.Start(RenkoWindow);
      if(RenkoTimer>0) EventSetMillisecondTimer(RenkoTimer);
   }
   
   IndicadoresOperacao.IncializaIndicadores(posicoes,mediaRapida, media, mediaLonga); 
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   RenkoOffline.Stop();
  }
//+------------------------------------------------------------------+
//| Tick Event (for testing purposes only)                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsStopped() && !ModoBackTeste) RenkoOffline.Refresh();
   AtualizarIndicadores();
   MudouCadle();
   
   
   
   
   
   
  }
//+------------------------------------------------------------------+
//| Book Event                                                       |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
  {
   OnTick();
  }
//+------------------------------------------------------------------+
//| Timer Event (Turn off when backtesting)                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
  }
//+------------------------------------------------------------------+


void AtualizarIndicadores()
{

   IndicadoresOperacao.AtualizaIndicadoresTick(posicoes,valorPorTick); 
   ValorMediaCurtaTick = valorPorTick[0];   
   
   CopyRates(Symbol(), Period(), 1, 1, BarData);
   
     

   PrecoFechamentoUltimoCandle = BarData[0].close;
   PrecoAberturaUltimoCandle = BarData[0].open;
   
   PrecoTick = SymbolInfoDouble(_Symbol, SYMBOL_LAST); 
   
   

    /*CopyRates(Symbol(), Period(), 1, 1, BarData);

    PrecoTick = SymbolInfoDouble(_Symbol, SYMBOL_LAST);   

    PrecoFechamentoUltimoCandle = BarData[0].close;
    PrecoAberturaUltimoCandle = BarData[0].open;
    
    IndicadoresOperacao.AtualizaIndicadoresTick(posicoes,valorPorTick);        
    
    ValorMediaCurtaTick = valorPorTick[0];
    //ValorMediaTick = valorPorTick[1];
    //ValorMediaLongaTick = valorPorTick[2];
    ValorBandaSuperiorTick = valorPorTick[3];
    ValorBandaInferiorTick = valorPorTick[4];
    ValorMACDTick = valorPorTick[5];

    ValorBandaSuperiorTickNormalizada = ValorBandaSuperiorTick - MathMod(ValorBandaSuperiorTick, 5);
    ValorBandaInferiorTickNormalizada = ValorBandaInferiorTick - MathMod(ValorBandaInferiorTick, 5);
    ValorMACDTickNormalizada = ValorMACDTick - MathMod(ValorMACDTick, 5);
    ValorMediaCurtaTickNormalizada = ValorMediaCurtaTick - MathMod(ValorMediaCurtaTick, 5);
    ValorMediaTickNormalizada = ValorMediaTick - MathMod(ValorMediaTick, 5);
    ValorMediaLongaTickNormalizada = ValorMediaLongaTick - MathMod(ValorMediaLongaTick, 5);


    if (IndicadoresOperacao.OrdemAberta(Symbol()))
    {

        PositionTicket = PositionGetInteger(POSITION_TICKET);
        StopLossCorrente = PositionGetDouble(POSITION_SL);
        GainCorrente = PositionGetDouble(POSITION_TP);
        PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);
    }
    */

}

void MudouCadle()
{
    if (PrecoFechamentoUltimoCandle != PrecoFechamentoPenultimoCandle)
    {
        PrecoFechamentoPenultimoCandle = PrecoFechamentoUltimoCandle;       
        
        mudouCandle = true;
        
    }

    else
    {
        mudouCandle = false;
    }
}
