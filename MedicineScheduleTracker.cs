using System;
using System.Collections.Generic;
using System.Linq;

namespace MedicineScheduleTracker
{
    class Medicine
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Dosage { get; set; }
        public string TimeOfDay { get; set; }
        public bool IsTaken { get; set; }

        public Medicine(int id, string name, string dosage, string timeOfDay)
        {
            Id        = id;
            Name      = name;
            Dosage    = dosage;
            TimeOfDay = timeOfDay;
            IsTaken   = false;
        }

        public override string ToString()
        {
            string status = IsTaken ? "[TAKEN]" : "[PENDING]";
            return $"  {status}  ID:{Id}  {Name} | {Dosage} | {TimeOfDay}";
        }
    }

    class ScheduleTracker
    {
        private List<Medicine> _medicines = new List<Medicine>();
        private int _nextId = 1;

        public void AddMedicine(string name, string dosage, string timeOfDay)
        {
            _medicines.Add(new Medicine(_nextId++, name, dosage, timeOfDay));
            Console.WriteLine($"\n  >> '{name}' added to schedule.");
        }

        public void ViewSchedule()
        {
            if (_medicines.Count == 0)
            {
                Console.WriteLine("\n  No medicines in schedule yet.");
                return;
            }

            Console.WriteLine("\n  ====== Today's Medicine Schedule ======");
            foreach (string slot in new[] { "Morning", "Afternoon", "Night" })
            {
                var slotMeds = _medicines.Where(m => m.TimeOfDay == slot).ToList();
                if (slotMeds.Count > 0)
                {
                    Console.WriteLine($"\n  -- {slot} --");
                    slotMeds.ForEach(m => Console.WriteLine(m));
                }
            }

            int taken   = _medicines.Count(m => m.IsTaken);
            int pending = _medicines.Count - taken;
            Console.WriteLine($"\n  Summary: {taken} taken, {pending} pending out of {_medicines.Count} total.");
        }

        public void MarkAsTaken(int id)
        {
            Medicine med = _medicines.FirstOrDefault(m => m.Id == id);
            if (med == null)
            {
                Console.WriteLine($"\n  No medicine found with ID {id}.");
                return;
            }
            med.IsTaken = true;
            Console.WriteLine($"\n  >> '{med.Name}' marked as taken.");
        }

        public void RemoveMedicine(int id)
        {
            Medicine med = _medicines.FirstOrDefault(m => m.Id == id);
            if (med == null)
            {
                Console.WriteLine($"\n  No medicine found with ID {id}.");
                return;
            }
            _medicines.Remove(med);
            Console.WriteLine($"\n  >> '{med.Name}' removed from schedule.");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            ScheduleTracker tracker = new ScheduleTracker();

            tracker.AddMedicine("Vitamin D3",      "1 tablet",   "Morning");
            tracker.AddMedicine("Iron Supplement", "1 capsule",  "Afternoon");
            tracker.AddMedicine("Omega-3",         "2 softgels", "Night");

            Console.WriteLine("\n  === Medicine Schedule Tracker ===");
            Console.WriteLine("  Developed by Saswat Mohallick\n");

            bool running = true;
            while (running)
            {
                Console.WriteLine("\n  1. View Schedule");
                Console.WriteLine("  2. Add Medicine");
                Console.WriteLine("  3. Mark Medicine as Taken");
                Console.WriteLine("  4. Remove Medicine");
                Console.WriteLine("  5. Exit");
                Console.Write("\n  Choose an option: ");

                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        tracker.ViewSchedule();
                        break;

                    case "2":
                        Console.Write("\n  Medicine name                 : ");
                        string name = Console.ReadLine();
                        Console.Write("  Dosage                        : ");
                        string dosage = Console.ReadLine();
                        Console.Write("  Time (Morning/Afternoon/Night): ");
                        string time = Console.ReadLine();
                        tracker.AddMedicine(name, dosage, time);
                        break;

                    case "3":
                        tracker.ViewSchedule();
                        Console.Write("\n  Enter ID to mark as taken: ");
                        if (int.TryParse(Console.ReadLine(), out int tid))
                            tracker.MarkAsTaken(tid);
                        break;

                    case "4":
                        tracker.ViewSchedule();
                        Console.Write("\n  Enter ID to remove: ");
                        if (int.TryParse(Console.ReadLine(), out int rid))
                            tracker.RemoveMedicine(rid);
                        break;

                    case "5":
                        running = false;
                        Console.WriteLine("\n  Goodbye. Stay healthy!\n");
                        break;

                    default:
                        Console.WriteLine("\n  Invalid option. Try again.");
                        break;
                }
            }
        }
    }
}
