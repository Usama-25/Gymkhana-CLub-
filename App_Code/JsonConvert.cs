using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;

namespace Newtonsoft.Json
{
    public static class JsonConvert
    {
        public static string SerializeObject(object obj)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            js.MaxJsonLength = int.MaxValue;
            if (obj is DataTable)
            {
                DataTable dt = (DataTable)obj;
                List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
                foreach (DataRow dr in dt.Rows)
                {
                    Dictionary<string, object> row = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        row.Add(col.ColumnName, dr[col] == DBNull.Value ? null : dr[col]);
                    }
                    rows.Add(row);
                }
                return js.Serialize(rows);
            }
            return js.Serialize(obj);
        }

        public static T DeserializeObject<T>(string json)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            js.MaxJsonLength = int.MaxValue;
            return js.Deserialize<T>(json);
        }
    }
}
