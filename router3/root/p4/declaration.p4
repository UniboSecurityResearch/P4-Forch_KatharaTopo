/* Copyright 2022 P4lang Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Example custom extern function.
extern void md5_hash_256<T, B>(inout T a, in B b);
extern void md5_hash_512<T, B, C>(inout T a, in B b, in C c);
extern void md5_hash_1024<T, B, C, D, E>(inout T a, in B b, in C c, in D d, in E e);

/*
// Example custom extern object.
extern CustomCounter<T> {
    CustomCounter(T init_count);
    void reset();
    void read(out T count);
    void increment_by(in T amount);
}*/
