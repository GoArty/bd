using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace AdoNet
{
    class lab_12_gorbunov
    {
        static void Main(string[] args)
        {
            // Связной уровень
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            SqlDataAdapter adapter = new SqlDataAdapter();

            // Просмотр содержимого таблицы
            ViewTableContents(connectionString);

            // Вставка данных
            InsertData(connectionString, adapter);

            // Изменение данных
            UpdateData(connectionString);

            // Удаление данных
            DeleteData(connectionString);

            // Несвязной уровень
            DataTable dataTable = DownloadTable(connectionString, adapter);

            // Удаление данных на несвязном уровне
            DeleteDataDisconnected(dataTable);

            // Обновление данных на несвязном уровне
            UpdateDataDisconnected(dataTable);

            // Добавление данных на несвязном уровне
            InsertDataDisconnected(dataTable);

            // Просмотр содержимого таблицы
            ViewTableDisconnected(dataTable);

            // Замена таблицы на сервере таблицей, использованной на несвязном уровне
            ReplaceTableOnServer(connectionString, dataTable, adapter);
        }

        static void ViewTableContents(string connectionString)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = $"SELECT * FROM Students";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                Console.Write($"{reader.GetName(i)}: {reader[i]}\t");
                            }
                            Console.WriteLine();
                        }
                    }
                }
            }
        }

        static void InsertData(string connectionString, SqlDataAdapter adapter)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = "INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email) VALUES (@StudentsID, @report_card, @first_name, @last_name, @date_of_birth, @enrollment_date, @email)";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@StudentsID", 4);
                    command.Parameters.AddWithValue("@report_card", 91);
                    command.Parameters.AddWithValue("@first_name", "John1");
                    command.Parameters.AddWithValue("@last_name", "Doe");
                    command.Parameters.AddWithValue("@date_of_birth", "2005-11-01");
                    command.Parameters.AddWithValue("@enrollment_date", "2025-09-21");
                    command.Parameters.AddWithValue("@email", "john.doe@example.com");

                    command.ExecuteNonQuery();
                }
            }
        }

        static void UpdateData(string connectionString)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = $"UPDATE Students SET report_card = 95 WHERE StudentsID = 1";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.ExecuteNonQuery();
                }
            }
        }

        static void DeleteData(string connectionString)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = $"DELETE FROM Students WHERE StudentsID = 2";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.ExecuteNonQuery();
                }
            }
        }

        static DataTable DownloadTable(string connectionString, SqlDataAdapter adapter)
        {
            DataTable dataTable = new DataTable();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = $"SELECT * FROM Students";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    adapter.SelectCommand = command;
                    adapter.Fill(dataTable);
                    dataTable.PrimaryKey = new DataColumn[] { dataTable.Columns["StudentsID"] };
                }
            }
            return dataTable;
        }

        static void DeleteDataDisconnected(DataTable dataTable)
        {
            DataRow rowToDelete = dataTable.Rows.Find(2);
            if (rowToDelete != null)
            {
                dataTable.Rows.Remove(rowToDelete);
            }
        }

        static void UpdateDataDisconnected(DataTable dataTable)
        {
            DataRow rowToUpdate = dataTable.Rows.Find(1);
            if (rowToUpdate != null)
            {
                rowToUpdate["report_card"] = 95;
            }
        }

        static void InsertDataDisconnected(DataTable dataTable)
        {
            DataRow newRow = dataTable.NewRow();
            newRow["StudentsID"] = 5;
            newRow["report_card"] = 92;
            newRow["first_name"] = "Jane2";
            newRow["last_name"] = "Doe";
            newRow["date_of_birth"] = "2006-12-01";
            newRow["enrollment_date"] = "2025-09-22";
            newRow["email"] = "jane.doe@example.com";
            dataTable.Rows.Add(newRow);
        }

        static void ReplaceTableOnServer(string connectionString, DataTable dataTable, SqlDataAdapter adapter)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                adapter.SelectCommand = new SqlCommand("SELECT * FROM Students", connection);

                adapter.InsertCommand = new SqlCommand(
                    "INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email) " +
                    "VALUES (@StudentsID, @report_card, @first_name, @last_name, @date_of_birth, @enrollment_date, @email)", connection);
                adapter.InsertCommand.Parameters.Add("@StudentsID", SqlDbType.Int, 0, "StudentsID");
                adapter.InsertCommand.Parameters.Add("@report_card", SqlDbType.Int, 0, "report_card");
                adapter.InsertCommand.Parameters.Add("@first_name", SqlDbType.NVarChar, 50, "first_name");
                adapter.InsertCommand.Parameters.Add("@last_name", SqlDbType.NVarChar, 50, "last_name");
                adapter.InsertCommand.Parameters.Add("@date_of_birth", SqlDbType.Date, 0, "date_of_birth");
                adapter.InsertCommand.Parameters.Add("@enrollment_date", SqlDbType.Date, 0, "enrollment_date");
                adapter.InsertCommand.Parameters.Add("@email", SqlDbType.NVarChar, 50, "email");

                adapter.UpdateCommand = new SqlCommand(
                    "UPDATE Students SET report_card = @report_card, first_name = @first_name, last_name = @last_name, " +
                    "date_of_birth = @date_of_birth, enrollment_date = @enrollment_date, email = @email " +
                    "WHERE StudentsID = @StudentsID", connection);
                adapter.UpdateCommand.Parameters.Add("@StudentsID", SqlDbType.Int, 0, "StudentsID");
                adapter.UpdateCommand.Parameters.Add("@report_card", SqlDbType.Int, 0, "report_card");
                adapter.UpdateCommand.Parameters.Add("@first_name", SqlDbType.NVarChar, 50, "first_name");
                adapter.UpdateCommand.Parameters.Add("@last_name", SqlDbType.NVarChar, 50, "last_name");
                adapter.UpdateCommand.Parameters.Add("@date_of_birth", SqlDbType.Date, 0, "date_of_birth");
                adapter.UpdateCommand.Parameters.Add("@enrollment_date", SqlDbType.Date, 0, "enrollment_date");
                adapter.UpdateCommand.Parameters.Add("@email", SqlDbType.NVarChar, 50, "email");

                adapter.DeleteCommand = new SqlCommand(
                    "DELETE FROM Students WHERE StudentsID = @StudentsID", connection);
                adapter.DeleteCommand.Parameters.Add("@StudentsID", SqlDbType.Int, 0, "StudentsID");

                adapter.Update(dataTable);
            }
        }

        static void ViewTableDisconnected(DataTable dataTable)
        {
            // Вывод данных из DataTable
            foreach (DataRow row in dataTable.Rows)
            {
                foreach (var item in row.ItemArray)
                {
                    Console.Write($"{item}\t");
                }
                Console.WriteLine();
            }
        }
    }
}
