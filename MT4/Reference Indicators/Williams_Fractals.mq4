#property copyright "ProTradersNetwork"
#property version   "1.00"
#property strict

#property indicator_plots   2
#property indicator_buffers 2

//---- input
extern int n = 2; // Periods, minimum value is 2

//---- buffers
double UpFractalBuffer[];
double DownFractalBuffer[];

//---- plot settings
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrTeal
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#define UP_FRACTAL_ARROW    233
#define DOWN_FRACTAL_ARROW  234

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, UpFractalBuffer);
   SetIndexBuffer(1, DownFractalBuffer);

   ArraySetAsSeries(UpFractalBuffer, false);
   ArraySetAsSeries(DownFractalBuffer, false);

   SetIndexArrow(0, UP_FRACTAL_ARROW);
   SetIndexArrow(1, DOWN_FRACTAL_ARROW);

   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);

   IndicatorShortName("Williams Fractals Non-Series (" + IntegerToString(n) + ")");
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

// minimal bars required
   int required_bars = 2 * n + 5;
   if(rates_total < required_bars)
      return (0);

   int _start = (prev_calculated == 0) ? n + 4 : prev_calculated - 1;
   if(_start < n + 4)
      _start = n + 4;
   if(_start >= rates_total)
      _start = rates_total - 1;

   if(rates_total!=prev_calculated && prev_calculated<=0)
     {
      ArraySetAsSeries(time,false);
      ArraySetAsSeries(open,false);
      ArraySetAsSeries(high,false);
      ArraySetAsSeries(low,false);
      ArraySetAsSeries(close,false);
      calculate(0,rates_total-1,open,high,low,close,time);
     }
   else
      if(rates_total!=prev_calculated && prev_calculated>0)
        {
         ArraySetAsSeries(time,false);
         ArraySetAsSeries(open,false);
         ArraySetAsSeries(high,false);
         ArraySetAsSeries(low,false);
         ArraySetAsSeries(close,false);
         calculate(prev_calculated-1,rates_total-1,open,high,low,close,time);
        }

   return (rates_total);
  }
//+------------------------------------------------------------------+
void calculate(int _start,int end,const double &open[],const double &high[],const double &low[],const double &close[],const datetime &time[])
  {
   for(int i = _start; i < end - n - 4; i++)
     {
      bool  downFlagPast = true;
      bool  downFrontier = false;

      // past comparison
      for(int j = 1; j <= n; j++)
        {
         if(i - j < 0)
           {
            downFlagPast = false;
            break;
           }
         downFlagPast = downFlagPast && (low[i - j] > low[i]);
        }

      // future comparison
      bool downFront[5] = {true, true, true, true, true};

      for(int j = 1; j <= n; j++)
        {
         if(i + j+4 >= end)
            break;

         // down conditions
         downFront[0] = downFront[0] && (low[i + j] > low[i]);
         downFront[1] = downFront[1] && (low[i + j + 1] > low[i] && low[i + 1] >= low[i]);
         downFront[2] = downFront[2] && (low[i + j + 2] > low[i] && low[i + 1] >= low[i] && low[i + 2] >= low[i]);
         downFront[3] = downFront[3] && (low[i + j + 3] > low[i] && low[i + 1] >= low[i] && low[i + 2] >= low[i] && low[i + 3] >= low[i]);
         downFront[4] = downFront[4] && (low[i + j + 4] > low[i] && low[i + 1] >= low[i] && low[i + 2] >= low[i] && low[i + 3] >= low[i] && low[i + 4] >= low[i]);
        }

      for(int k = 0; k < 5; k++)
        {
         downFrontier = downFrontier || downFront[k];
        }

      bool downFractal = downFlagPast && downFrontier;
      if(downFractal)
        {
         DownFractalBuffer[i] = low[i] - (Point * 5);
         UpFractalBuffer[i] = 0.0;
        }
      else
        {
         UpFractalBuffer[i] = 0.0;
         DownFractalBuffer[i] = 0.0;
        }
     }
  }
//+------------------------------------------------------------------+
