using System;
using System.Collections.Generic;

using Newtonsoft.Json;

namespace RentalOffer.Core {

    public class NeedPacket {

        public const string NEED = "car_rental_offer";

        private List<object> solutions = new List<object>();

        public IList<object> Solutions {
            get { return solutions.AsReadOnly(); }
        }

        public NeedPacket() {}

        public string ToJson() {
            // Clumsy, but this seems easier than dealing with
            // Json.Net's idiosyncrasies to get snake-cased keys.
            IDictionary<string, object> toJson = new Dictionary<string, object>();
            toJson.Add("json_class", this.GetType().FullName);
            toJson.Add("need", NEED);
            toJson.Add("solutions", solutions);

            return JsonConvert.SerializeObject(toJson);
        }

        public void ProposeSolution(Object solution) {
            solutions.Add(solution);
        }

    }

}

