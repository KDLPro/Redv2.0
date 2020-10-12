import java.util.Scanner;
import java.util.Arrays;

public class RemoveElements {
	public static void main (String[] args) {

		Scanner scan = new Scanner(System.in);
		System.out.print("How many elements in the array? ");
		int elements = scan.nextInt();
		int[] arr = new int[elements];

		for (int i = 0; i < elements; i++){
			System.out.print("Input array elements (" + (elements - i) + " left): ");
			arr[i] = scan.nextInt();
		}
		
		System.out.println();
		System.out.print("Please enter the array element to be removed: ");
		int toRemove = scan.nextInt();

		int finalLength = arr.length;		//final length of the array after removing element

		int startIndex = Arrays.binarySearch(arr, toRemove);
		System.out.println(startIndex);

		if (startIndex > -1){					//if element is present in the array
			finalLength--;
			int[] finalArray = new int[finalLength];
			for (int i = 0; i < finalLength; i++){
				if (i < startIndex){
					finalArray[i] = arr[i];
				} else{
					finalArray[i] = arr[i + 1];
				}
			}
			System.out.println("Original Array:" + Arrays.toString(arr));
			System.out.println("Array after removing element:" + Arrays.toString(finalArray));
		} else{
			
			System.out.println("Original Array:" + Arrays.toString(arr));
			System.out.println("Array after removing element:" + Arrays.toString(arr));
		}

		

	}
}
