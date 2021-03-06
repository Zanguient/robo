#property copyright "Copyright 2019, Leonardo Bezerra."
#property link      "leonardoab89@gmail.com"
#property version   "1.0"
#property description "ROBO LAB"
#include <RenkoCharts.mqh>
#include <Indicadores.mqh>

/* ======================================== RENKO =============================================================*/

// Inputs
//input string ativo = ""; 
string RenkoSymbol = "";
input bool modoBack = true;                             // GERAL =============== Modo back teste 
input string AtivoEscolhido = "WDOX19";                                   // GERAL =============== Ativo 
input bool CarregarHistorico = true;                       // GERAL =============== Criar renko e carregar Historico
input ENUM_RENKO_WINDOW RenkoWindow = RENKO_NEW_WINDOW;    // GERAL =============== Abrir estrategia

string Ativo = AtivoEscolhido;

input float loss = 3.5;                                      // GERAL =============== Valor em pontos Loss
input float gain = 2;                                      // GERAL =============== Valor em pontos Gain
input int QtdContratos = 1;                                // GERAL =============== Quantidade de Contratos

input string horarioFechar = "17:00";                  // FECHAMENTO  =============== Fechar posiooes abertar apos horario

input float Ticks_Weis_1 = 1.5;                            // WEIS 1 =============== Quantidade de Pontos
input bool Entrada_Ticks_Weis_1 = true;                    // WEIS 1 =============== Considerar Sinal
input float Ticks_Weis_2 = 3;                              // WEIS 2 =============== Quantidade de Pontos
input bool Entrada_Ticks_Weis_2 = false;                   // WEIS 2 =============== Considerar Sinal
input float Ticks_Weis_3 = 4.5;                            // WEIS 3 =============== Quantidade de Pontos
input bool Entrada_Ticks_Weis_3 = false;                   // WEIS 3 =============== Considerar Sinal

input bool usarHorarioEntrada = false;                     // H OPERAR =============== Ligar Indicador? 
input string horarioInicioPrimeiro = "09:00";             // H OPERAR =============== Inicio entrada primeiro periodo
input string horariofimPrimeiro = "11:30";             // H OPERAR =============== Final entrada primeiro periodo
input string horarioInicioSegundo = "14:00";              // H OPERAR =============== Inicio entrada primeiro periodo
input string horariofimSegundo = "16:30";              // H OPERAR =============== Final entrada primeiro periodo


input bool ligarRenko = false;                             // RENKO=========== Ligar Indicador? 
input double RenkoSize = 4;                                // RENKO =============== Size(R)
input int RenkoTimer = 100;                                // RENKO =============== Tempo Atualizacao Grafico em milliseconds 


input bool usarADX = false;                                // ADX =============== Ligar Indicador? 
input int mediaADX = 9;                                    // ADX ================= Valor da Media do ADX
input float valorRefernciaADX = 0;                         // ADX ================= Valor Minimo ADX
bool crescenteadx = false;                                 // ADX ================= Valor Crescente

input bool usarmedia = false;                              // MEDIA =============== Ligar Indicador?
input int mediaRapida = 144;                               // MEDIA =============== Valor EXP Acima/Abaixo

input bool usarMACD = false;                               // MACD =============== Ligar Indicador? 
input int mediaLongaMACD = 26;                             // MACD =============== Media Longa MACD
input int mediaCurtaMACD = 12;                             // MACD =============== Media Curta MACD
input int sinalMACD = 9;                                   // MACD =============== Sinal MACD
input int valorMVenda = 20;                                // MACD =============== Valor minimo para venda
input int valorMCompra = 0;                                // MACD =============== Valor minimo para compra

input bool usaVolume = false;                              // VOLUME =============== Ligar Indicador? 
input ENUM_TIMEFRAMES tempoGrafico = PERIOD_M1;            // VOLUME =============== Tempo grafico cheio
input ENUM_APPLIED_VOLUME tipoVolume = VOLUME_TICK;        // VOLUME =============== Tipo Volume a ser considerado
input int mediaVolume = 6;                                 // VOLUME =============== Valor Media Volume
input string codigoCheio = "DOL@D";                    // VOLUME =============== Codigo ativo cheio

input bool usaTrail = false;                               // TRAIL =============== Ligar Indicador? 
input float distranciaGain = 1;                            // TRAIL =============== Distancia do Gain para Ativar (Em Pontos)
input float distrancialossPreco = 1;                       // TRAIL =============== Distancia do Novo Loss do Preco (Em Pontos)
input float proximoAlvo = 2;                               // TRAIL =============== Proximo Alvo                  (Em Pontos)

input bool usarBandas = false;                            // BANDAS =============== Ligar Indicador? 
input float mediaBandas = 20;                              // BANDAS =============== Media das bandas
input float desvioBandas = 2;                              // BANDAS =============== Desvio
input float desvioDistanciaBandas = 0;                     // BANDAS =============== Valor Minimo de desvio


/* ============================================================================================================*/

ENUM_RENKO_TYPE RenkoType = RENKO_TYPE_TICKS;              //Type
bool RenkoWicks = true;                                    //Show Wicks

string AtivoRenko = "";

int posicoes[7];
//string ativofinal = "";

int media = 50;             // Média
int mediaLonga = 100;       // Média Longa

double valorPorTick[12];

double ValorMediaCurtaTick = 0;
double ValorADXTick = 0;
double ValorADXCandleAnterior = 0;
double ValorVolumeAnterior = 0;
double ValorMediaVolume = 0;

MqlRates BarData[195];


double PrecoTick;
double PrecoFechamentoUltimoCandle;
double PrecoAberturaUltimoCandle;
double PrecoFechamentoPenultimoCandle = 1;

bool mudouCandle = false;

string operacaoWeis_1 = "Nada";
string operacaoWeis_2 = "Nada";
string operacaoWeis_3 = "Nada";

int contadorWeis[3];
string sinalWeis[3];

double bufferWW[];
double ultimaReferencia = 0;

double valorUltimoTopo = 0;
double valorUltimoFundo = 1000000;

double ValorBandaInferiorTick;
double ValorBandaSuperiorTick;
double ValorBandaMeioTick;

double ValorMACDTick;

float desvioPadrao = 0;



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

    if (CarregarHistorico)
    {
        //Get Symbol
        if (RenkoSymbol != "")
            original_symbol = RenkoSymbol;
        //Check Period
        if (RenkoWindow == RENKO_CURRENT_WINDOW && ChartPeriod(0) != PERIOD_M1)
        {
            MessageBox("Renko must be M1 period!", __FILE__, MB_OK);
            ChartSetSymbolPeriod(0, Ativo, PERIOD_M1);
            return (INIT_SUCCEEDED);
        }
        //Check Symbol
        if (!RenkoOffline.ValidateSymbol(original_symbol))
        {
            MessageBox("Invalid symbol error. Select a valid symbol!", __FILE__, MB_OK);
            return (INIT_FAILED);
        }
        //Setup Renko
        if (!RenkoOffline.Setup(original_symbol, RenkoType, RenkoSize, RenkoWicks))
        {
            MessageBox("Renko setup error. Check error log!", __FILE__, MB_OK);
            return (INIT_FAILED);
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
        if (RenkoTimer > 0) EventSetMillisecondTimer(RenkoTimer);
    }

    AtivoRenko = Ativo + "_" + IntegerToString(RenkoSize) + "TICKS";

    

    IndicadoresOperacao.IncializaIndicadores(posicoes, mediaRapida, media, mediaLonga, mediaADX, tempoGrafico, tipoVolume, codigoCheio, mediaLongaMACD, mediaCurtaMACD, sinalMACD, mediaBandas, desvioBandas, AtivoRenko, PERIOD_M1);

    contadorWeis[0] = 0;
    contadorWeis[1] = 0;
    contadorWeis[2] = 0;

    sinalWeis[0] = "";
    sinalWeis[1] = "";
    sinalWeis[2] = "";


    return (INIT_SUCCEEDED);
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
    if (!IsStopped() && CarregarHistorico) RenkoOffline.Refresh();
    AtualizarIndicadores();
    MudouCadle();

    


    if (usaTrail) IndicadoresOperacao.StopGainMovel(distranciaGain, distrancialossPreco, proximoAlvo, Ativo, PrecoTick);
    IndicadoresOperacao.horarioFecharPosicao(horarioFechar, PrecoTick, Ativo);


    if (mudouCandle)
    {
        operacaoWeis_1 = weis(Ticks_Weis_1, Entrada_Ticks_Weis_1, 0);
        operacaoWeis_2 = weis(Ticks_Weis_2, Entrada_Ticks_Weis_2, 1);
        operacaoWeis_3 = weis(Ticks_Weis_3, Entrada_Ticks_Weis_3, 2);

        desvioPadrao = (ValorBandaSuperiorTick - ValorBandaInferiorTick) / 6;
        
        
        
        Comment("WEIS 1:" + operacaoWeis_1 + "Tempo: " + contadorWeis[0] +
              "\nWEIS 2:" + operacaoWeis_2 + "Tempo: " + contadorWeis[1] +
              "\nWEIS 3:" + operacaoWeis_3 + "Tempo: " + contadorWeis[2] +
              "\nValor Ultimo Fundo: " + valorUltimoFundo +
              "\nValor Ultimo Topo: "  + valorUltimoTopo 
        
        );



        if (
             operacaoWeis_1 == "Venda"
          && operacaoWeis_2 == "Venda"
          && operacaoWeis_3 == "Venda"
          && (ValorMediaCurtaTick > PrecoFechamentoUltimoCandle || !usarmedia)
          && (ValorADXTick > valorRefernciaADX || !usarADX)
          && (ValorADXTick > ValorADXCandleAnterior || !crescenteadx || !usarADX)
          && (IndicadoresOperacao.horariOperar(horarioInicioPrimeiro, horariofimPrimeiro, horarioInicioSegundo, horariofimSegundo) || !usarHorarioEntrada)
          && (valorMVenda > ValorMACDTick || !usarMACD)
          && (ValorMediaVolume < ValorVolumeAnterior || !usaVolume)
          && (desvioPadrao < desvioDistanciaBandas || !usarBandas)
          )
        {
            IndicadoresOperacao.Venda(loss, gain, Ativo, QtdContratos);
        }
        else if (
                  operacaoWeis_1 == "Compra"
               && operacaoWeis_2 == "Compra"
               && operacaoWeis_3 == "Compra"
               && (ValorMediaCurtaTick < PrecoFechamentoUltimoCandle || !usarmedia)
               && (ValorADXTick > valorRefernciaADX || !usarADX)
               && (ValorADXTick > ValorADXCandleAnterior || !crescenteadx || !usarADX)
               && (IndicadoresOperacao.horariOperar(horarioInicioPrimeiro, horariofimPrimeiro, horarioInicioSegundo, horariofimSegundo) || !usarHorarioEntrada)
               && (valorMCompra < ValorMACDTick || !usarMACD)
               && (desvioPadrao < desvioDistanciaBandas || !usarBandas)
               && (ValorMediaVolume < ValorVolumeAnterior || !usaVolume)
               )
        {
            IndicadoresOperacao.Compra(loss, gain, Ativo, QtdContratos);


        }
    }
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

    IndicadoresOperacao.AtualizaIndicadoresTick(posicoes, valorPorTick, mediaVolume);
    ValorMediaCurtaTick = valorPorTick[0];
    ValorADXCandleAnterior = valorPorTick[7];
    ValorADXTick = valorPorTick[6];
    ValorMediaVolume = valorPorTick[8];
    ValorVolumeAnterior = valorPorTick[10];

    int i = 194;

    CopyRates(AtivoRenko, PERIOD_M1, 1, 195, BarData);

    int k;

    for (k = 0; BarData[k].close == 0; k--)
    {
        i--;
    }

    PrecoFechamentoUltimoCandle = BarData[i].close;
    PrecoAberturaUltimoCandle = BarData[i].open;

    PrecoTick = SymbolInfoDouble(AtivoRenko, SYMBOL_LAST);

    ValorBandaSuperiorTick = valorPorTick[3];
    ValorBandaInferiorTick = valorPorTick[4];
    ValorMACDTick = valorPorTick[5];

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

string weis(int ticks, bool sinalTrigger, int weis)
{

    int i = 194;

    int k;

    for (k = 0; BarData[k].close == 0; k--)
    {
        i--;
    }


    if (ultimaReferencia == 0) ultimaReferencia = BarData[i].close;

    if (BarData[i].close >= BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Compra"))
    {
        sinalWeis[weis] = "Compra";
        contadorWeis[weis]++;

        if (sinalTrigger) return "Nada";
        else return "Compra";
    }

    else if (BarData[i].close >= BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Venda"))
    {
        int x = 0;
        valorUltimoFundo = 1000000;

        for (x = 0; x < contadorWeis[weis]; x++)
        {
            if (BarData[i - x].close < valorUltimoFundo) valorUltimoFundo = BarData[i - x].close;
        }

        if (BarData[i].close - valorUltimoFundo > ticks)
        {
            sinalWeis[weis] = "Compra";
            contadorWeis[weis] = 0;
            return "Compra";
        }

        else
        {
            sinalWeis[weis] = "Venda";
            contadorWeis[weis]++;
            if (sinalTrigger) return "Nada";
            else return "Venda";
        }
    }
    else if (BarData[i].close < BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Compra"))
    {
        valorUltimoTopo = 0;
        int x = 0;

        for (x = 0; x < contadorWeis[weis]; x++)
        {
            if (BarData[i - x].close > valorUltimoTopo) valorUltimoTopo = BarData[i - x].close;
        }

        if (valorUltimoTopo - BarData[i].close > ticks)
        {
            sinalWeis[weis] = "Venda";
            contadorWeis[weis] = 0;
            return "Venda";
        }

        else
        {
            sinalWeis[weis] = "Compra";
            contadorWeis[weis]++;

            if (sinalTrigger) return "Nada";
            else return "Compra";
        }

    }
    else if (BarData[i].close < BarData[i - 1].close && (sinalWeis[weis] == "" || sinalWeis[weis] == "Venda"))
    {
        sinalWeis[weis] = "Venda";
        contadorWeis[weis]++;

        if (sinalTrigger) return "Nada";
        else return "Venda";
    }

    return "Nada";
}