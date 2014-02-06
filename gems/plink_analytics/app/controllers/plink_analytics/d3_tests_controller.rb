module PlinkAnalytics
  class D3TestsController < ApplicationController
    def pie_chart_test_data
      render json: [
        {age: "<5", population: "2704659"},
        {age: "5-13", population: "4499890"},
        {age: "14-17", population: "2159981"},
        {age: "18-24", population: "3853788"},
        {age: "25-44", population: "14106543"},
        {age: "45-64", population: "8819342"},
        {age: ">=65", population: "612463"}
      ]
    end

    def bullet_chart_test_data
      render json: [
        {title:"Revenue",subtitle:"US$, in thousands",measures:[220,270],markers:[250]},
        {title:"Profit",subtitle:"%",measures:[21,23],markers:[26]},
        {title:"Order Size",subtitle:"US$, average",measures:[100,320],markers:[550]},
        {title:"New Customers",subtitle:"count",measures:[1000,1650],markers:[2100]},
        {title:"Satisfaction",subtitle:"out of 5",measures:[3.2,4.7],markers:[4.4]}
      ]
    end
  end
end
