using NegrBlazor.Models;

namespace NegrBlazor.Clients
{
	public class NegrStorageClient
	{
		private List<NegrClass> Storage = new()
		{
			new(){ Id = 0, Name = "Вова", Age = 0, Weight = 0M, Price = 0M },
			new(){ Id = 1, Name = "Федк", Age = 10, Weight = 10M, Price = 10M },
			new(){ Id = 2, Name = "Бомж", Age = 100, Weight = 100M, Price = 100M },
		};

		public NegrClass[] GetNegrs() => [.. Storage];

		public void AddNegr(NegrClass negr) => Storage.Add(negr);
	}
}
