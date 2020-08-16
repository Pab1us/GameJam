using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomPlatform : MonoBehaviour
{
    public GameObject[] platforms;
    public GameObject[] platforms2;
    public GameObject[] platforms3;
    public GameObject[] platforms4;
    public GameObject[] platforms5;
    public GameObject[] platforms6;
    public GameObject[] platforms7;
    public GameObject[] platforms8;
    public GameObject[] platforms9;
    public GameObject[] platforms10;
    private int mode;
    // Start is called before the first frame update
    void Start()
    {
        //Random mode
        System.Random rand = new System.Random();
        mode = rand.Next(1, 6);
        #region 1 ряд
        for (int i = platforms.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения platforms[j] и platforms[i]
            var temp = platforms[j];
            platforms[j] = platforms[i];
            platforms[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i==0)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms[i].transform.position = new Vector3(transform.position.x, transform.position.y, 3.9f);
            }


        }
        mode = rand.Next(2, 7);
        if (mode == 2)
        {
            platforms[0].SetActive(false);
            platforms[1].SetActive(false);
            platforms[2].SetActive(true);
            platforms[3].SetActive(true);
            platforms[4].SetActive(false);
            platforms[5].SetActive(false);

        }
        else if (mode == 3)
        {
            platforms[0].SetActive(false);
            platforms[1].SetActive(true);
            platforms[2].SetActive(true);
            platforms[3].SetActive(true);
            platforms[4].SetActive(false);
            platforms[5].SetActive(false);

        }
        else if (mode == 4)
        {
            platforms[0].SetActive(false);
            platforms[1].SetActive(true);
            platforms[2].SetActive(true);
            platforms[3].SetActive(true);
            platforms[4].SetActive(true);
            platforms[5].SetActive(false);

        }
        else if (mode == 5)
        {
            platforms[0].SetActive(true);
            platforms[1].SetActive(true);
            platforms[2].SetActive(true);
            platforms[3].SetActive(true);
            platforms[4].SetActive(true);
            platforms[5].SetActive(false);

        }
        else if (mode == 6)
        {
            platforms[0].SetActive(true);
            platforms[1].SetActive(true);
            platforms[2].SetActive(true);
            platforms[3].SetActive(true);
            platforms[4].SetActive(true);
            platforms[5].SetActive(true);

        }
        #endregion

        #region 2 ряд
        for (int i = platforms2.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms2[j];
            platforms2[j] = platforms2[i];
            platforms2[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms2[i].transform.position = new Vector3(transform.position.x + 1.3f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms2[0].SetActive(false);
                platforms2[1].SetActive(false);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(false);
                platforms2[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms2[0].SetActive(false);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(false);
                platforms2[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms2[0].SetActive(false);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(true);
                platforms2[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms2[0].SetActive(true);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(true);
                platforms2[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms2[0].SetActive(true);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(true);
                platforms2[5].SetActive(true);

            }

        }
        #endregion

        #region 3 ряд
        for (int i = platforms3.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms3[j];
            platforms3[j] = platforms3[i];
            platforms3[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms3[i].transform.position = new Vector3(transform.position.x + 2.6f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms3[0].SetActive(false);
                platforms3[1].SetActive(false);
                platforms3[2].SetActive(true);
                platforms3[3].SetActive(true);
                platforms3[4].SetActive(false);
                platforms3[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms3[0].SetActive(false);
                platforms3[1].SetActive(true);
                platforms3[2].SetActive(true);
                platforms3[3].SetActive(true);
                platforms3[4].SetActive(false);
                platforms3[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms3[0].SetActive(false);
                platforms3[1].SetActive(true);
                platforms3[2].SetActive(true);
                platforms3[3].SetActive(true);
                platforms3[4].SetActive(true);
                platforms3[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms3[0].SetActive(true);
                platforms3[1].SetActive(true);
                platforms3[2].SetActive(true);
                platforms3[3].SetActive(true);
                platforms3[4].SetActive(true);
                platforms3[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms3[0].SetActive(true);
                platforms3[1].SetActive(true);
                platforms3[2].SetActive(true);
                platforms3[3].SetActive(true);
                platforms3[4].SetActive(true);
                platforms3[5].SetActive(true);

            }
        }
        #endregion

        #region 4 ряд
        for (int i = platforms4.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms4[j];
            platforms4[j] = platforms4[i];
            platforms4[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms4[i].transform.position = new Vector3(transform.position.x + 3.9f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms4[0].SetActive(false);
                platforms4[1].SetActive(false);
                platforms4[2].SetActive(true);
                platforms4[3].SetActive(true);
                platforms4[4].SetActive(false);
                platforms4[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms4[0].SetActive(false);
                platforms4[1].SetActive(true);
                platforms4[2].SetActive(true);
                platforms4[3].SetActive(true);
                platforms4[4].SetActive(false);
                platforms4[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms4[0].SetActive(false);
                platforms4[1].SetActive(true);
                platforms4[2].SetActive(true);
                platforms4[3].SetActive(true);
                platforms4[4].SetActive(true);
                platforms4[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms4[0].SetActive(true);
                platforms4[1].SetActive(true);
                platforms4[2].SetActive(true);
                platforms4[3].SetActive(true);
                platforms4[4].SetActive(true);
                platforms4[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms4[0].SetActive(true);
                platforms4[1].SetActive(true);
                platforms4[2].SetActive(true);
                platforms4[3].SetActive(true);
                platforms4[4].SetActive(true);
                platforms4[5].SetActive(true);

            }
        }
        #endregion

        #region 5 ряд
        for (int i = platforms5.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms5[j];
            platforms5[j] = platforms5[i];
            platforms5[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms5[i].transform.position = new Vector3(transform.position.x + 5.2f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms5[0].SetActive(false);
                platforms5[1].SetActive(false);
                platforms5[2].SetActive(true);
                platforms5[3].SetActive(true);
                platforms5[4].SetActive(false);
                platforms5[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms5[0].SetActive(false);
                platforms5[1].SetActive(true);
                platforms5[2].SetActive(true);
                platforms5[3].SetActive(true);
                platforms5[4].SetActive(false);
                platforms5[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms5[0].SetActive(false);
                platforms5[1].SetActive(true);
                platforms5[2].SetActive(true);
                platforms5[3].SetActive(true);
                platforms5[4].SetActive(true);
                platforms5[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms5[0].SetActive(true);
                platforms5[1].SetActive(true);
                platforms5[2].SetActive(true);
                platforms5[3].SetActive(true);
                platforms5[4].SetActive(true);
                platforms5[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms5[0].SetActive(true);
                platforms5[1].SetActive(true);
                platforms5[2].SetActive(true);
                platforms5[3].SetActive(true);
                platforms5[4].SetActive(true);
                platforms5[5].SetActive(true);

            }
        }
        #endregion

        #region 6 ряд
        for (int i = platforms6.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms6[j];
            platforms6[j] = platforms6[i];
            platforms6[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms6[i].transform.position = new Vector3(transform.position.x + 6.5f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms6[0].SetActive(false);
                platforms6[1].SetActive(false);
                platforms6[2].SetActive(true);
                platforms6[3].SetActive(true);
                platforms6[4].SetActive(false);
                platforms6[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms6[0].SetActive(false);
                platforms6[1].SetActive(true);
                platforms6[2].SetActive(true);
                platforms6[3].SetActive(true);
                platforms6[4].SetActive(false);
                platforms6[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms6[0].SetActive(false);
                platforms6[1].SetActive(true);
                platforms6[2].SetActive(true);
                platforms6[3].SetActive(true);
                platforms6[4].SetActive(true);
                platforms6[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms6[0].SetActive(true);
                platforms6[1].SetActive(true);
                platforms6[2].SetActive(true);
                platforms6[3].SetActive(true);
                platforms6[4].SetActive(true);
                platforms6[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms6[0].SetActive(true);
                platforms6[1].SetActive(true);
                platforms6[2].SetActive(true);
                platforms6[3].SetActive(true);
                platforms6[4].SetActive(true);
                platforms6[5].SetActive(true);

            }
        }
        #endregion
        #region 7 ряд
        for (int i = platforms7.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms7[j];
            platforms7[j] = platforms7[i];
            platforms7[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms7[i].transform.position = new Vector3(transform.position.x + 7.8f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms7[0].SetActive(false);
                platforms7[1].SetActive(false);
                platforms7[2].SetActive(true);
                platforms7[3].SetActive(true);
                platforms7[4].SetActive(false);
                platforms7[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms7[0].SetActive(false);
                platforms7[1].SetActive(true);
                platforms7[2].SetActive(true);
                platforms7[3].SetActive(true);
                platforms7[4].SetActive(false);
                platforms7[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms7[0].SetActive(false);
                platforms7[1].SetActive(true);
                platforms7[2].SetActive(true);
                platforms7[3].SetActive(true);
                platforms7[4].SetActive(true);
                platforms7[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms7[0].SetActive(true);
                platforms7[1].SetActive(true);
                platforms7[2].SetActive(true);
                platforms7[3].SetActive(true);
                platforms7[4].SetActive(true);
                platforms7[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms7[0].SetActive(true);
                platforms7[1].SetActive(true);
                platforms7[2].SetActive(true);
                platforms7[3].SetActive(true);
                platforms7[4].SetActive(true);
                platforms7[5].SetActive(true);

            }
        }
        #endregion
        #region 8 ряд
        for (int i = platforms8.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms8[j];
            platforms8[j] = platforms8[i];
            platforms8[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms8[i].transform.position = new Vector3(transform.position.x + 9.1f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms2[0].SetActive(false);
                platforms2[1].SetActive(false);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(false);
                platforms2[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms2[0].SetActive(false);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(false);
                platforms2[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms2[0].SetActive(false);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(true);
                platforms2[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms2[0].SetActive(true);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(true);
                platforms2[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms2[0].SetActive(true);
                platforms2[1].SetActive(true);
                platforms2[2].SetActive(true);
                platforms2[3].SetActive(true);
                platforms2[4].SetActive(true);
                platforms2[5].SetActive(true);

            }
        }
        #endregion

        #region 9 ряд
        for (int i = platforms9.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms9[j];
            platforms9[j] = platforms9[i];
            platforms9[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms9[i].transform.position = new Vector3(transform.position.x + 10.4f, transform.position.y, 3.9f);
            }
            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms9[0].SetActive(false);
                platforms9[1].SetActive(false);
                platforms9[2].SetActive(true);
                platforms9[3].SetActive(true);
                platforms9[4].SetActive(false);
                platforms9[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms9[0].SetActive(false);
                platforms9[1].SetActive(true);
                platforms9[2].SetActive(true);
                platforms9[3].SetActive(true);
                platforms9[4].SetActive(false);
                platforms9[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms9[0].SetActive(false);
                platforms9[1].SetActive(true);
                platforms9[2].SetActive(true);
                platforms9[3].SetActive(true);
                platforms9[4].SetActive(true);
                platforms9[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms9[0].SetActive(true);
                platforms9[1].SetActive(true);
                platforms9[2].SetActive(true);
                platforms9[3].SetActive(true);
                platforms9[4].SetActive(true);
                platforms9[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms9[0].SetActive(true);
                platforms9[1].SetActive(true);
                platforms9[2].SetActive(true);
                platforms9[3].SetActive(true);
                platforms9[4].SetActive(true);
                platforms9[5].SetActive(true);

            }

        }
        #endregion

        #region 10 ряд
        for (int i = platforms10.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms10[j];
            platforms10[j] = platforms10[i];
            platforms10[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i == 0)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, -3.9f);
            }
            else if (i == 1)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, -2.6f);
            }
            else if (i == 2)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, -1.3f);
            }
            else if (i == 3)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, 0);
            }
            else if (i == 4)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, 1.3f);
            }
            else if (i == 5)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, 2.6f);
            }
            else if (i == 6)
            {
                platforms10[i].transform.position = new Vector3(transform.position.x + 11.7f, transform.position.y, 3.9f);
            }

            mode = rand.Next(2, 7);
            if (mode == 2)
            {
                platforms10[0].SetActive(false);
                platforms10[1].SetActive(false);
                platforms10[2].SetActive(true);
                platforms10[3].SetActive(true);
                platforms10[4].SetActive(false);
                platforms10[5].SetActive(false);

            }
            else if (mode == 3)
            {
                platforms10[0].SetActive(false);
                platforms10[1].SetActive(true);
                platforms10[2].SetActive(true);
                platforms10[3].SetActive(true);
                platforms10[4].SetActive(false);
                platforms10[5].SetActive(false);

            }
            else if (mode == 4)
            {
                platforms10[0].SetActive(false);
                platforms10[1].SetActive(true);
                platforms10[2].SetActive(true);
                platforms10[3].SetActive(true);
                platforms10[4].SetActive(true);
                platforms10[5].SetActive(false);

            }
            else if (mode == 5)
            {
                platforms10[0].SetActive(true);
                platforms10[1].SetActive(true);
                platforms10[2].SetActive(true);
                platforms10[3].SetActive(true);
                platforms10[4].SetActive(true);
                platforms10[5].SetActive(false);

            }
            else if (mode == 6)
            {
                platforms10[0].SetActive(true);
                platforms10[1].SetActive(true);
                platforms10[2].SetActive(true);
                platforms10[3].SetActive(true);
                platforms10[4].SetActive(true);
                platforms10[5].SetActive(true);

            }
        }
        #endregion
    }
    public void StartRandom()
    {
        
    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
