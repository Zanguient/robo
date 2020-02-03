//+------------------------------------------------------------------+
//|                                               ROBOLAB_CANDLE.mq5 |
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


input string cabecario1;      // ====== ALVO/LOSS - NORMAL ========
input int qtdContratos = 2;   // Quantidade de contratos /2
input double gain = 50;        // GAIN Minimo
input double loss = 500;       // LOSS Maximo
input string cabecario16;             // ====== HORARIOS =================
input string horarioAbrMin = "09:00"; // Abertura MIN
input string horarioAbrMax = "17:00"; // Abertura MAX
input string horarioFecMax = "17:30"; // Fechamento MAX



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int ultimoCandle = 0;

int mPivot;
int mMacd;

double PPBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];
double macdArray[];

double VPPBuffer;
double VS1Buffer;
double VR1Buffer;
double VS2Buffer;
double VR2Buffer;
double VS3Buffer;
double VR3Buffer;

int contador = 0;
ENUM_ORDER_TYPE tipoOrdem;

int div;

double precoAtual;

double PrecoFechamentoPenultimoCandle = 1;

MqlRates BarData[1];

bool ordemAberta = false;
bool mudouCandle = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   mPivot = iCustom(_Symbol, _Period, "pivotpoint");
   mMacd = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
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
    mudouCandle = VerificarMudouCandle();

    if (mudouCandle)
    {
    
    fecharTodasOrdensPendentes();
    
    ordemAberta = OrdemAberta(_Symbol);
    
    if (ordemAberta) 
    {
    horarioFecharPosicaoIndice(horarioFecMax, SymbolInfoDouble(_Symbol, SYMBOL_LAST), _Symbol, qtdContratos);
    contador++;
    
    //if (contador == 3) horarioFecharPosicaoIndice3();
    
    }
    
    //if(ordemAberta)horarioFecharPosicaoIndice();
    
    
    
    
    ArraySetAsSeries(macdArray, true);
    CopyBuffer(mMacd, 0, 0, 3, macdArray);

   ArraySetAsSeries(PPBuffer, true);
   ArraySetAsSeries(S1Buffer, true);
   ArraySetAsSeries(R1Buffer, true);
   ArraySetAsSeries(S2Buffer, true);
   ArraySetAsSeries(R2Buffer, true);
   ArraySetAsSeries(S3Buffer, true);
   ArraySetAsSeries(R3Buffer, true);
   
   
   CopyBuffer(mPivot, 0, 0, 3, R3Buffer);
   CopyBuffer(mPivot, 1, 0, 3, R2Buffer);
   CopyBuffer(mPivot, 2, 0, 3, R1Buffer);
   CopyBuffer(mPivot, 3, 0, 3, PPBuffer);
   CopyBuffer(mPivot, 4, 0, 3, S1Buffer);
   CopyBuffer(mPivot, 5, 0, 3, S2Buffer);
   CopyBuffer(mPivot, 6, 0, 3, S3Buffer);
   
   
    div = PPBuffer[0] / 5;
   
    VPPBuffer = div * 5 ;
    
    div = S1Buffer[0] / 5;
    
    VS1Buffer = div * 5 ;
    
    div = R1Buffer[0] / 5;
    
    VR1Buffer = div * 5 ;
    
    div = S2Buffer[0] / 5;
    
    VS2Buffer = div * 5 ;
    
    div = R2Buffer[0] / 5;
    
    VR2Buffer = div * 5 ;
    
    div = S3Buffer[0] / 5;
    
    VS3Buffer = div * 5 ;
    
    div = R3Buffer[0] / 5;
    
    VR3Buffer = div * 5 ;
   
    precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
    
    
    if (macdArray[0] > 0 && !ordemAberta && horaOperar(horarioAbrMax)){
    
    contador = 0;
    
    
    if (VPPBuffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VPPBuffer,VPPBuffer,VPPBuffer - loss ,VPPBuffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
     
    if (VS1Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VS1Buffer,VS1Buffer,VS1Buffer - loss ,VS1Buffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
     
    if (VS2Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VS2Buffer,VS2Buffer,VS2Buffer - loss ,VS2Buffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
     
    if (VS3Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VS3Buffer,VS3Buffer,VS3Buffer - loss ,VS3Buffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
     
    if (VR1Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VR1Buffer,VR1Buffer,VR1Buffer - loss ,VR1Buffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
     
    if (VR2Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VR2Buffer,VR2Buffer,VR2Buffer - loss ,VR2Buffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
     
    if (VR3Buffer > precoAtual) tipoOrdem = ORDER_TYPE_BUY_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_BUY_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VR3Buffer,VR3Buffer,VR3Buffer - loss ,VR3Buffer + gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
    
    
    
    
    }
    
    else if (macdArray[0] < 0 && !ordemAberta && horaOperar(horarioAbrMax)){
    
    contador = 0;
    
    if (VPPBuffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VPPBuffer,VPPBuffer,VPPBuffer + loss ,VPPBuffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
    if (VS1Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VS1Buffer,VS1Buffer,VS1Buffer + loss ,VS1Buffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));


    if (VR1Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VR1Buffer,VR1Buffer,VR1Buffer + loss ,VR1Buffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));

     if (VS2Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VS2Buffer,VS2Buffer,VS2Buffer + loss ,VS2Buffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
    
    if (VR2Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VR2Buffer,VR2Buffer,VR2Buffer + loss ,VR2Buffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));


if (VS3Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VS3Buffer,VS3Buffer,VS3Buffer + loss ,VS3Buffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));


if (VR3Buffer < precoAtual) tipoOrdem = ORDER_TYPE_SELL_STOP_LIMIT;
    else tipoOrdem = ORDER_TYPE_SELL_LIMIT;    
    
    operacao.OrderOpen(_Symbol,tipoOrdem,qtdContratos,VR3Buffer,VR3Buffer,VR3Buffer + loss ,VR3Buffer - gain ,ORDER_TIME_SPECIFIED,TimeTradeServer() + PeriodSeconds(PERIOD_M5));
     

    
    
    }
    
   
   
   
  

   
   
   }




   
  }
//+------------------------------------------------------------------+



bool VerificarMudouCandle()
{
    if (BarData[ultimoCandle].close != PrecoFechamentoPenultimoCandle)
    {
        PrecoFechamentoPenultimoCandle = BarData[ultimoCandle].close;
        return true;
    }

    else
        return false;
}

bool OrdemAberta(string ativo)
{
    if (PositionSelect(ativo) == true)
        return true;
    else
        return false;
}

void fecharTodasOrdensPendentes()
{


    uint total=OrdersTotal();
    int i;
    
    for(uint i=0;i<total;i++)
    
    {

    MqlTradeRequest request = {0};
    MqlTradeResult result = {0};

    ulong order_ticket = OrderGetTicket(0);

    ZeroMemory(request);
    ZeroMemory(result);
    //--- setting the operation parameters
    request.action = TRADE_ACTION_REMOVE;
    request.order = order_ticket;

   if (order_ticket != 0) 
   
   {
   OrderSend(request, result);
   
   }
   
   }
       
}

void horarioFecharPosicaoIndice3()
{


    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    

    

    
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          //  operacao.PositionModify(PositionTicket, precoAtual + 20, precoAtual - 20);
        operacao.Sell(qtdContratos, _Symbol, precoAtual);

        else
            operacao.Buy(qtdContratos, _Symbol, precoAtual);
          //  operacao.PositionModify(PositionTicket, precoAtual - 20, precoAtual + 20);

    }



bool horarioFecharPosicaoIndice(string horarioMaximo, float precoAtual, string ativo, int tamanhoLote)
{


    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double GainCorrente = PositionGetDouble(POSITION_TP);
    double PrecoAberturaPosicao = PositionGetDouble(POSITION_PRICE_OPEN);

    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2019.01.01 " + horaCorrenteStr);

    if (StringToTime("2019.01.01 " + horaCorrenteStr) > StringToTime("2019.01.01 " + horarioMaximo))
    {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          //  operacao.PositionModify(PositionTicket, precoAtual + 20, precoAtual - 20);
        operacao.Sell(tamanhoLote, ativo, precoAtual);

        else
            operacao.Buy(tamanhoLote, ativo, precoAtual);
          //  operacao.PositionModify(PositionTicket, precoAtual - 20, precoAtual + 20);

        return true;

    }
    else return false;

}

bool horaOperar(string inicioPrimeiroPeriodo)
{
    datetime horaCorrente = TimeCurrent();

    string horaCorrenteStr = TimeToString(horaCorrente, TIME_MINUTES);

    horaCorrente = StringToTime("2019.01.01 " + horaCorrenteStr);

    if (StringToTime("2019.01.01 " + horaCorrenteStr) <= StringToTime("2019.01.01 " + inicioPrimeiroPeriodo))
    {
        return true;
    }
    else
    {
        return false;
    }
}